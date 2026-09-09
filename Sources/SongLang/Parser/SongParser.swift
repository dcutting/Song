import Foundation

public final class SongParser {
    public init() {}

    public func parse(_ input: String) throws -> Expression {
        switch parseResult(input) {
        case let .success(expression):
            return expression
        case let .incomplete(error), let .failure(error):
            throw error
        }
    }

    public func parseResult(_ input: String) -> SongParseResult {
        do {
            var lexer = Lexer(input: input)
            let tokens = try lexer.tokenize()
            var parser = SongTokenParser(tokens: tokens)
            return .success(try parser.parseRoot())
        } catch let error as SongParseError {
            return error.isIncomplete ? .incomplete(error) : .failure(error)
        } catch {
            return .failure(.invalidToken("\(error)"))
        }
    }
}

private struct ParsedExpression {
    let expression: Expression
    let isCallable: Bool
    let allowsDot: Bool
    let allowsTrailingCall: Bool
}

private struct SongTokenParser {
    private var tokens: [Token]
    private var index = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    mutating func parseRoot() throws -> Expression {
        let expression = try parseStatement().expression
        guard isAtEnd else {
            throw unexpected(expected: "end of input")
        }
        return expression
    }

    private mutating func parseStatement() throws -> ParsedExpression {
        if hasTopLevelEqual {
            if isVariableDeclarationShape {
                return try parseVariableDeclaration()
            }
            return try parseFunctionDeclaration()
        }
        return try parseExpression()
    }

    private mutating func parseFunctionDeclaration() throws -> ParsedExpression {
        if isSubjectFunctionDeclarationShape {
            return try parseSubjectFunctionDeclaration()
        }
        return try parseFreeFunctionDeclaration()
    }

    private mutating func parseSubjectFunctionDeclaration() throws -> ParsedExpression {
        let subject = try parseFunctionPattern()
        try expect(.dot, expected: ".")
        let name = try parseFunctionName()
        let patterns = try parseOptionalParameterList() ?? []
        let when = try parseWhenClause()
        try expect(.equal, expected: "=")
        let body = try parseExpression().expression
        return parsed(.function(Function(
            name: name,
            patterns: [subject] + patterns,
            when: when,
            body: body
        )))
    }

    private mutating func parseFreeFunctionDeclaration() throws -> ParsedExpression {
        let name = try parseFunctionName()
        let patterns = try parseParameterList()
        let when = try parseWhenClause()
        try expect(.equal, expected: "=")
        let body = try parseExpression().expression
        return parsed(.function(Function(name: name, patterns: patterns, when: when, body: body)))
    }

    private mutating func parseVariableDeclaration() throws -> ParsedExpression {
        let variable = try parseVariable()
        try expect(.equal, expected: "=")
        let value = try parseExpression().expression
        return parsed(.assign(variable: variable, value: value))
    }

    private mutating func parseWhenClause() throws -> Expression {
        guard match(.when) != nil else {
            return .yes
        }
        return try parseExpression().expression
    }

    private mutating func parseExpression() throws -> ParsedExpression {
        try parseDisjunctive()
    }

    private mutating func parseDisjunctive() throws -> ParsedExpression {
        let left = try parseConjunctive()
        if let op = try matchWordOperator([.or]) {
            let right = try parseDisjunctive()
            return parsed(.call(op.text, [left.expression, right.expression]))
        }
        return left
    }

    private mutating func parseConjunctive() throws -> ParsedExpression {
        let left = try parseEquality()
        if let op = try matchWordOperator([.and]) {
            let right = try parseConjunctive()
            return parsed(.call(op.text, [left.expression, right.expression]))
        }
        return left
    }

    private mutating func parseEquality() throws -> ParsedExpression {
        let left = try parseRelational()
        if let op = try matchWordOperator([.eq, .neq]) {
            let right = try parseEquality()
            return parsed(.call(op.text, [left.expression, right.expression]))
        }
        return left
    }

    private mutating func parseRelational() throws -> ParsedExpression {
        var result = try parseAdditive()
        while let op = match([.leq, .geq, .lt, .gt]) {
            let right = try parseAdditive()
            result = parsed(.call(op.text, [result.expression, right.expression]))
        }
        return result
    }

    private mutating func parseAdditive() throws -> ParsedExpression {
        var result = try parseMultiplicative()
        while let op = match([.plus, .minus]) {
            let right = try parseMultiplicative()
            result = parsed(.call(op.text, [result.expression, right.expression]))
        }
        return result
    }

    private mutating func parseMultiplicative() throws -> ParsedExpression {
        var result = try parsePower()
        while true {
            if let op = match([.star, .slash, .percent]) {
                let right = try parsePower()
                result = parsed(.call(op.text, [result.expression, right.expression]))
            } else if let op = try matchWordOperator([.div, .mod]) {
                let right = try parsePower()
                result = parsed(.call(op.text, [result.expression, right.expression]))
            } else {
                return result
            }
        }
    }

    private mutating func parsePower() throws -> ParsedExpression {
        let left = try parseUnary()
        guard match(.caret) != nil else {
            return left
        }
        let right = try parsePower()
        return parsed(.call("^", [left.expression, right.expression]))
    }

    private mutating func parseUnary() throws -> ParsedExpression {
        if check(.not) {
            let op = try matchPrefixWordOperator(.not)
            let right = try parseUnary()
            return parsed(.call(op.text, [right.expression]))
        }
        return try parsePostfix()
    }

    private mutating func parseSigned() throws -> ParsedExpression {
        if match(.minus) != nil {
            let right = try parseSigned()
            return literal(.call("-", [right.expression]))
        }
        if match(.plus) != nil {
            return try parseSigned()
        }
        return try parsePrimary()
    }

    private mutating func parsePostfix() throws -> ParsedExpression {
        var result = try parseSigned()
        while true {
            if result.allowsTrailingCall, check(.lParen) {
                let arguments = try parseArgumentList()
                result = callable(.eval(result.expression, arguments))
            } else if result.allowsDot, match(.dot) != nil {
                result = try parseDotContinuation(head: result.expression)
            } else {
                return result
            }
        }
    }

    private mutating func parsePrimary() throws -> ParsedExpression {
        guard let token = current else {
            throw SongParseError.unexpectedEnd(expected: "expression")
        }

        switch token.kind {
        case let .name(name):
            advance()
            if check(.lParen) {
                return callable(.call(name, try parseArgumentList()))
            }
            return ParsedExpression(
                expression: name == "_" ? .unnamed : .name(name),
                isCallable: true,
                allowsDot: true,
                allowsTrailingCall: false
            )
        case let .integer(value):
            advance()
            guard let integer = IntType(value) else {
                throw SongParseError.invalidNumber(value)
            }
            return parseNumericLiteralSuffixUnit(.int(integer))
        case let .float(value):
            advance()
            guard let float = FloatType(value) else {
                throw SongParseError.invalidNumber(value)
            }
            return parseNumericLiteralSuffixUnit(.float(float))
        case let .string(value):
            advance()
            return literal(.string(value))
        case let .character(value):
            advance()
            return literal(.char(value))
        case .yes:
            advance()
            return literal(.yes)
        case .no:
            advance()
            return literal(.no)
        case .lBracket:
            return literal(try parseListOrCons())
        case .lParen:
            return try parseWrappedExpression()
        case .pipe:
            return try parseLambda()
        case .do:
            return try parseScope()
        default:
            throw unexpected(expected: "expression")
        }
    }

    private mutating func parseWrappedExpression() throws -> ParsedExpression {
        try expect(.lParen, expected: "(")
        let expression = try parseExpression()
        try expect(.rParen, expected: ")")
        return ParsedExpression(
            expression: expression.expression,
            isCallable: expression.isCallable,
            allowsDot: true,
            allowsTrailingCall: expression.isCallable
        )
    }

    private mutating func parseListOrCons() throws -> Expression {
        try expect(.lBracket, expected: "[")
        if match(.rBracket) != nil {
            return .list([])
        }

        var items = [try parseExpression().expression]
        while match(.comma) != nil {
            items.append(try parseExpression().expression)
        }

        if match(.pipe) != nil {
            let tail = try parseExpression().expression
            try expect(.rBracket, expected: "]")
            return .cons(items, tail)
        }

        try expect(.rBracket, expected: "]")
        return .list(items)
    }

    private mutating func parseLambda() throws -> ParsedExpression {
        try expect(.pipe, expected: "|")
        var patterns = [Expression]()
        if match(.pipe) == nil {
            patterns.append(try parseLambdaPattern())
            while match(.comma) != nil {
                patterns.append(try parseLambdaPattern())
            }
            try expect(.pipe, expected: "|")
        }
        let body = try parseExpression().expression
        return ParsedExpression(
            expression: .function(Function(name: nil, patterns: patterns, when: .yes, body: body)),
            isCallable: true,
            allowsDot: false,
            allowsTrailingCall: false
        )
    }

    private mutating func parseScope() throws -> ParsedExpression {
        try expect(.do, expected: "Do")
        guard current?.leadingWhitespace == true else {
            throw unexpected(expected: "whitespace")
        }

        var statements = [try parseStatement().expression]
        while true {
            if match(.comma) != nil {
                statements.append(try parseStatement().expression)
            } else if current?.leadingNewline == true, !check(.end) {
                statements.append(try parseStatement().expression)
            } else {
                break
            }
        }

        guard current?.leadingWhitespace == true else {
            throw unexpected(expected: "whitespace")
        }
        try expect(.end, expected: "End")
        return ParsedExpression(
            expression: .scope(statements),
            isCallable: true,
            allowsDot: false,
            allowsTrailingCall: false
        )
    }

    private mutating func parseDotContinuation(head: Expression) throws -> ParsedExpression {
        if case let .name(name) = current?.kind {
            advance()
            let arguments = check(.lParen) ? try parseArgumentList() : []
            return callable(.call(name, [head] + arguments))
        }

        if match(.lParen) != nil {
            let expression = try parseExpression()
            try expect(.rParen, expected: ")")

            var result: ParsedExpression
            if expression.isCallable {
                result = callable(.eval(expression.expression, [head]))
            } else if case let .call(name, arguments) = expression.expression {
                result = callable(.call(name, [head] + arguments))
            } else {
                throw unexpected(expected: "callable expression")
            }

            if check(.lParen) {
                result = callable(.eval(result.expression, try parseArgumentList()))
            }
            return result
        }

        throw unexpected(expected: "function name or callable expression")
    }

    private mutating func parseNumericLiteralSuffixUnit(_ number: Expression) -> ParsedExpression {
        guard let token = current,
              token.leadingWhitespace == false,
              case let .name(name) = token.kind,
              name != "_"
        else {
            return literal(number)
        }
        advance()
        return callable(.call(name, [number]))
    }

    private mutating func parseArgumentList() throws -> [Expression] {
        try expect(.lParen, expected: "(")
        if match(.rParen) != nil {
            return []
        }
        var arguments = [try parseExpression().expression]
        while match(.comma) != nil {
            arguments.append(try parseExpression().expression)
        }
        try expect(.rParen, expected: ")")
        return arguments
    }

    private mutating func parseParameterList() throws -> [Expression] {
        try expect(.lParen, expected: "(")
        if match(.rParen) != nil {
            return []
        }
        var parameters = [try parseFunctionPattern()]
        while match(.comma) != nil {
            parameters.append(try parseFunctionPattern())
        }
        try expect(.rParen, expected: ")")
        return parameters
    }

    private mutating func parseOptionalParameterList() throws -> [Expression]? {
        guard check(.lParen) else {
            return nil
        }
        return try parseParameterList()
    }

    private mutating func parseFunctionPattern() throws -> Expression {
        if let literal = attempt({ try $0.parsePatternLiteral() }) {
            return literal
        }
        return try parseVariable()
    }

    private mutating func parseLambdaPattern() throws -> Expression {
        if check(.lBracket) {
            return try parseListOrCons()
        }
        return try parseVariable()
    }

    private mutating func parsePatternLiteral() throws -> Expression {
        guard let token = current else {
            throw SongParseError.unexpectedEnd(expected: "pattern")
        }

        switch token.kind {
        case let .integer(value):
            advance()
            guard let integer = IntType(value) else {
                throw SongParseError.invalidNumber(value)
            }
            return .int(integer)
        case let .float(value):
            advance()
            guard let float = FloatType(value) else {
                throw SongParseError.invalidNumber(value)
            }
            return .float(float)
        case let .string(value):
            advance()
            return .string(value)
        case let .character(value):
            advance()
            return .char(value)
        case .yes:
            advance()
            return .yes
        case .no:
            advance()
            return .no
        case .lBracket:
            return try parseListOrCons()
        default:
            throw unexpected(expected: "literal")
        }
    }

    private mutating func parseVariable() throws -> Expression {
        guard case let .name(name) = current?.kind else {
            throw unexpected(expected: "name")
        }
        advance()
        return name == "_" ? .unnamed : .name(name)
    }

    private mutating func parseFunctionName() throws -> String {
        guard case let .name(name) = current?.kind else {
            throw unexpected(expected: "function name")
        }
        advance()
        return name
    }

    private func literal(_ expression: Expression) -> ParsedExpression {
        ParsedExpression(
            expression: expression,
            isCallable: false,
            allowsDot: true,
            allowsTrailingCall: false
        )
    }

    private func callable(_ expression: Expression) -> ParsedExpression {
        ParsedExpression(
            expression: expression,
            isCallable: true,
            allowsDot: true,
            allowsTrailingCall: true
        )
    }

    private func parsed(_ expression: Expression) -> ParsedExpression {
        ParsedExpression(
            expression: expression,
            isCallable: false,
            allowsDot: false,
            allowsTrailingCall: false
        )
    }

    private mutating func matchPrefixWordOperator(_ kind: TokenKind) throws -> TokenKind {
        guard let token = current, token.kind == kind else {
            throw unexpected(expected: kind.text)
        }
        guard let next = peek(), next.leadingWhitespace else {
            throw unexpected(expected: "whitespace")
        }
        advance()
        return token.kind
    }

    private mutating func matchWordOperator(_ kinds: [TokenKind]) throws -> TokenKind? {
        guard let token = current, kinds.contains(token.kind) else {
            return nil
        }
        guard token.leadingWhitespace else {
            return nil
        }
        guard let next = peek(), next.leadingWhitespace else {
            throw unexpected(expected: "whitespace")
        }
        advance()
        return token.kind
    }

    private mutating func match(_ kind: TokenKind) -> Token? {
        guard check(kind) else {
            return nil
        }
        return advance()
    }

    private mutating func match(_ kinds: [TokenKind]) -> TokenKind? {
        guard let token = current, kinds.contains(token.kind) else {
            return nil
        }
        advance()
        return token.kind
    }

    @discardableResult
    private mutating func expect(_ kind: TokenKind, expected: String) throws -> Token {
        guard let token = match(kind) else {
            throw unexpected(expected: expected)
        }
        return token
    }

    private func check(_ kind: TokenKind) -> Bool {
        current?.kind == kind
    }

    private var current: Token? {
        guard !isAtEnd else {
            return nil
        }
        return tokens[index]
    }

    private func peek() -> Token? {
        let next = index + 1
        guard next < tokens.count else {
            return nil
        }
        return tokens[next]
    }

    @discardableResult
    private mutating func advance() -> Token {
        let token = tokens[index]
        index += 1
        return token
    }

    private var isAtEnd: Bool {
        index >= tokens.count
    }

    private var hasTopLevelEqual: Bool {
        var parenDepth = 0
        var bracketDepth = 0
        var scopeDepth = 0

        for token in tokens[index...] {
            switch token.kind {
            case .lParen:
                parenDepth += 1
            case .rParen:
                parenDepth -= 1
            case .lBracket:
                bracketDepth += 1
            case .rBracket:
                bracketDepth -= 1
            case .do:
                scopeDepth += 1
            case .end:
                scopeDepth -= 1
            case .equal where parenDepth == 0 && bracketDepth == 0 && scopeDepth == 0:
                return true
            default:
                break
            }
        }
        return false
    }

    private var isVariableDeclarationShape: Bool {
        guard index + 1 < tokens.count else {
            return false
        }
        guard case .name = tokens[index].kind else {
            return false
        }
        return tokens[index + 1].kind == .equal
    }

    private var isSubjectFunctionDeclarationShape: Bool {
        var parenDepth = 0
        var bracketDepth = 0
        var scopeDepth = 0

        for token in tokens[index...] {
            switch token.kind {
            case .lParen:
                parenDepth += 1
            case .rParen:
                parenDepth -= 1
            case .lBracket:
                bracketDepth += 1
            case .rBracket:
                bracketDepth -= 1
            case .do:
                scopeDepth += 1
            case .end:
                scopeDepth -= 1
            case .dot where parenDepth == 0 && bracketDepth == 0 && scopeDepth == 0:
                return true
            case .equal where parenDepth == 0 && bracketDepth == 0 && scopeDepth == 0:
                return false
            default:
                break
            }
        }
        return false
    }

    private func unexpected(expected: String) -> SongParseError {
        guard let token = current else {
            return .unexpectedEnd(expected: expected)
        }
        return .unexpectedToken(token.kind.text, expected: expected)
    }

    private mutating func attempt<T>(_ parse: (inout SongTokenParser) throws -> T) -> T? {
        let start = index
        do {
            return try parse(&self)
        } catch {
            index = start
            return nil
        }
    }
}
