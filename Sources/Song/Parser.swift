import Syft

public func makeParser() -> ParserProtocol {

    // Punctuation.

    let newline = str("\n")
    let space = " \t".match.some
    let spaceOrNewline = space | newline
    let skip = space.maybe
    let skipSpaceAndNewlines = spaceOrNewline.some.maybe
    let dot = str(".")
    let pipe = str("|") >>> skip
    let comma = str(",")
    let delimiter = str(",")
    let lBracket = str("[")
    let rBracket = str("]")
    let lParen = str("(") >>> skip
    let rParen = str(")")
    let singleQuote = str("'")
    let quote = str("\"")
    let backslash = str("\\")
    let underscore = str("_")
    let questionMark = str("?")
    let digit = (0...9).match
    let lowercaseLetter = "abcdefghijklmnopqrstuvwxyz".match
    let uppercaseLetter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".match
    let letter = lowercaseLetter | uppercaseLetter
    let symbol = dot | pipe | comma | lBracket | rBracket | lParen | rParen | underscore | "!@#$%^&*-=_+`~,.<>/?:;\\|[]{}".match
    let textualCharacter = letter | digit | space | symbol
    let literalCharacter = backslash >>> (backslash | singleQuote) | textualCharacter | quote
    let literalString = Deferred()
    literalString.parser = backslash >>> (backslash | quote) | textualCharacter | singleQuote
    let star = str("*")
    let slash = str("/")
    let div = str("Div")
    let mod = str("Mod")
    let plus = str("+")
    let minus = str("-")
    let lessThanOrEqual = str("<=")
    let greaterThanOrEqual = str(">=")
    let lessThan = str("<")
    let greaterThan = str(">")
    let equalTo = str("Eq")
    let notEqualTo = str("Neq")
    let logicalAnd = str("And")
    let logicalOr = str("Or")
    let logicalNot = str("Not")
    let yes = str("Yes")
    let no = str("No")
    let when = spaceOrNewline >>> str("When") >>> spaceOrNewline
    let assign = str("=")
    let start = str("Do")
    let end = str("End")

    let expression = Deferred()
    let wrappedExpression = lParen >>> expression.tag("wrapped") >>> rParen

    let scope = Deferred()

    // Lists.

    let listItem = skip >>> (expression.tag("item") | newline) >>> skip
    let listItemDelimiter = skipSpaceAndNewlines >>> comma >>> skipSpaceAndNewlines
    let listItems = listItem >>> (listItemDelimiter >>> listItem).recur
    let list = lBracket >>> skipSpaceAndNewlines >>> listItems.recur.tag("list") >>> skipSpaceAndNewlines >>> rBracket

    let heads = listItems.tag("heads")
    let tail = expression.tag("tail")
    let listConstructor = lBracket >>> skipSpaceAndNewlines >>> heads >>> skipSpaceAndNewlines >>> pipe >>> skipSpaceAndNewlines >>> tail >>> skipSpaceAndNewlines >>> rBracket

    // Literals.

    let trueValue = yes.tag("true")
    let falseValue = no.tag("false")
    let booleanValue = trueValue | falseValue
    let integerValue = digit.some.tag("integer")
    let floatValue = (digit.some >>> dot >>> digit.some).tag("float")
    let numericValue = floatValue | integerValue
    let characterValue = singleQuote >>> literalCharacter.tag("character") >>> singleQuote
    let stringValue = quote >>> literalString.some.maybe.tag("string") >>> quote

    let literalValue = stringValue | characterValue | list | listConstructor | numericValue | booleanValue

    // Names.

    let namePrefix = underscore | lowercaseLetter
    let nameSuffix = letter | digit | underscore | questionMark
    let name = namePrefix >>> nameSuffix.some.maybe
    let variableName = name.tag("variableName")
    let functionName = name.tag("functionName")

    // Function calls.

    let arg = expression.tag("arg")
    let argumentDelimiter = skipSpaceAndNewlines >>> comma >>> skipSpaceAndNewlines
    let args = skipSpaceAndNewlines >>> (arg >>> (argumentDelimiter >>> arg).recur).tag("args") >>> skipSpaceAndNewlines
    let freeFunctionCall = functionName >>> (lParen >>> args.maybe >>> skip >>> rParen)
    let anonymousFunctionCall = Deferred()
    let subject = wrappedExpression | freeFunctionCall | literalValue | variableName
    let subjectFunctionCall = subject.tag("subject") >>> (dot >>> functionName >>> (lParen >>> args.maybe >>> rParen).maybe).some.tag("calls")
    anonymousFunctionCall.parser = subject.tag("anonSubject") >>> (lParen >>> args.maybe >>> rParen)
    let functionCall = anonymousFunctionCall | subjectFunctionCall | freeFunctionCall

    // Function declarations.

    let parameter = (literalValue | variableName).tag("param")
    let functionSubject = parameter.tag("subject")
    let parameterDelimiter = skipSpaceAndNewlines >>> comma >>> skipSpaceAndNewlines
    let parameters = parameter >>> (parameterDelimiter >>> parameter).recur
    let functionParameters = skipSpaceAndNewlines >>> lParen >>> skipSpaceAndNewlines >>> parameters.recur(0, 1).tag("params") >>> skipSpaceAndNewlines >>> rParen
    let functionBody = skip >>> (scope | expression).tag("body") >>> skip
    let guardClause = (when >>> expression).maybe.tag("guard") >>> skip
    let subjectFunctionDecl = functionSubject >>> dot >>> functionName >>> functionParameters.maybe >>> guardClause >>> assign >>> skipSpaceAndNewlines >>> functionBody

    let freeFunctionDecl = functionName >>> functionParameters >>> guardClause >>> assign >>> skipSpaceAndNewlines >>> functionBody

    let functionDecl = subjectFunctionDecl | freeFunctionDecl

    // Lambdas.

    let lambdaParameters = pipe >>> parameters.recur(0, 1).tag("params") >>> pipe
    let lambdaBody = expression.tag("lambdaBody")
    let lambda = lambdaParameters >>> lambdaBody

    // Expressions.

    let relational = Deferred()
    let equality = Deferred()
    let conjunctive = Deferred()
    let disjunctive = Deferred()
    let term = Deferred()

    let symbolicMultiplicativeOp = skipSpaceAndNewlines >>> (star | slash).tag("op") >>> skipSpaceAndNewlines
    let wordMultiplicativeOp = spaceOrNewline >>> (mod | div).tag("op") >>> spaceOrNewline
    let multiplicativeOp = symbolicMultiplicativeOp | wordMultiplicativeOp
    let multiplicative = term.tag("left") >>> (multiplicativeOp >>> term.tag("right")).recur.tag("ops")
    let additive = multiplicative.tag("left") >>> (skipSpaceAndNewlines >>> (plus | minus).tag("op") >>> skipSpaceAndNewlines >>> multiplicative.tag("right")).recur.tag("ops")
    relational.parser = additive.tag("left") >>> (skipSpaceAndNewlines >>> (lessThanOrEqual | greaterThanOrEqual | lessThan | greaterThan).tag("op") >>> skipSpaceAndNewlines >>> relational.tag("right")).recur.tag("ops")
    equality.parser = relational.tag("left") >>> (spaceOrNewline >>> (equalTo | notEqualTo).tag("op") >>> spaceOrNewline >>> equality.tag("right")).recur.tag("ops")
    conjunctive.parser = equality.tag("left") >>> (spaceOrNewline >>> logicalAnd.tag("op") >>> spaceOrNewline >>> conjunctive.tag("right")).recur.tag("ops")
    disjunctive.parser = conjunctive.tag("left") >>> (spaceOrNewline >>> logicalOr.tag("op") >>> spaceOrNewline >>> disjunctive.tag("right")).recur.tag("ops")

    expression.parser = disjunctive.parser

    // Terms.

    let negateOp = (logicalNot.tag("op") >>> spaceOrNewline) | minus.tag("op")
    let negateTerm = negateOp >>> term.tag("right")
    let plusTerm = plus >>> term
    term.parser = negateTerm | plusTerm | scope | functionCall | lambda | subject

    // Constants.

    let constant = variableName.tag("variable") >>> skipSpaceAndNewlines >>> assign >>> skipSpaceAndNewlines >>> (scope | expression).tag("constBody")

    // Scopes.

    let statement = Deferred()
    let scopeItem = skip >>> statement.tag("arg")
    let delimiterOrNewline = skip >>> ((delimiter.maybe >>> skip >>> newline) | delimiter)
    let scopeItems = (scopeItem >>> (delimiterOrNewline >>> scopeItem).recur).tag("scopeItems") >>> delimiter.maybe
    scope.parser = start >>> spaceOrNewline >>> skipSpaceAndNewlines >>> scopeItems >>> spaceOrNewline >>> skipSpaceAndNewlines >>> end
    statement.parser = skipSpaceAndNewlines >>> (functionDecl | lambda | constant | expression)

    // Root.

    let root = statement >>> skipSpaceAndNewlines

    return root
}

func makeFuncCall() -> ParserProtocol {

    let dot = str(".")
    let comma = str(",")
    let pipe = str("|")
    let lParen = str("(")
    let rParen = str(")")

    let int = "0123456789".match.some.tag("int")
    let name = "abcdefghijklmnopqrstuvwxyz".match.some.tag("var")
    let literal = int

    let call = Deferred()
    let expression = Deferred()
    let wrappedExpression = lParen >>> expression >>> rParen
    let callable = Deferred()

    let arg = expression.tag("arg")
    let args = (arg >>> (comma >>> arg).recur).tag("args").recur(0, 1)

    let lambda = (pipe >>> args >>> pipe >>> expression.tag("body")).tag("lambda")
    let wrappedLambda = lParen >>> lambda >>> rParen
    let called = (callable >>> (lParen >>> args.tag("do") >>> rParen).recur).tag("called")
    let subject = called | literal | wrappedExpression
    call.parser = subject.tag("subject") >>> (dot >>> called).recur.tag("chain")

    callable.parser = name | wrappedLambda | wrappedExpression

    expression.parser = call | callable | lambda | literal | wrappedExpression

    return call
}

public func makeCallParser() -> ParserProtocol {

    let pipe = str("|")
    let comma = str(",")
    let dot = str(".")
    let lParen = str("(")
    let rParen = str(")")
    let integer = "0123456789".match.some
    let name = "abcdefghijklmnopqrstuvwxyz".match.some

    let literal = integer.tag("int")
    let variable = name.tag("variableName")
    let value = Deferred()
    let lambda = Deferred()
    let call = Deferred()
    let wrappedValue = lParen >>> value >>> rParen
    value.parser = wrappedValue | call | lambda | literal | variable

    let param = variable
    let params = param >>> (comma >>> param).recur

    let arg = value
    let args = arg >>> (comma >>> arg).recur
    let wrappedArgs = lParen >>> args.recur.tag("args") >>> rParen

    lambda.parser = (pipe >>> params.tag("params") >>> pipe >>> value.tag("body")).tag("lambda")

    let callable = call | variable | lambda

    let groupName = name.tag("functionName")
    let groupAnon = lParen >>> callable >>> rParen
    let groupAnonCall = groupAnon.tag("anonCall") >>> wrappedArgs.maybe
    let groupAnonCallWithArgs = groupAnon.tag("anonCall") >>> wrappedArgs
    let groupNameCall = groupName >>> wrappedArgs
    let trailCalls = (lParen >>> args.recur.tag("args") >>> rParen).tag("anonCall").recur
    let dotGroupCall = groupNameCall.tag("nameCall") | groupAnonCall
    let headGroupCall = groupNameCall.tag("nameCall") | groupAnonCallWithArgs
    let group = dotGroupCall | groupName.tag("nameCall") | wrappedValue
    let dotHead = (headGroupCall >>> trailCalls).tag("trailCalls") | wrappedValue | variable | literal | lambda
    let dotGroup = dot >>> group
    let dotCall = dotHead.tag("head") >>> dotGroup >>> trailCalls >>> (dotGroup >>> trailCalls).recur

    let freeCall = (dotGroupCall >>> trailCalls).tag("trailCalls")

    call.parser = dotCall.tag("dotCall") | freeCall

    return call
}

public func makeCallTransformer() -> Transformer<Expression> {
    let t = Transformer<Expression>()

    t.rule(["int": .simple("n")]) {
        let n = try $0.str("n")
        guard let int = IntType(n) else { throw SongTransformError.notNumeric(n) }
        return .integerValue(int)
    }

    t.rule(["variableName": .simple("name")]) {
        .variable(try $0.str("name"))
    }

    t.rule(["args": .series("args")]) {
        .list(try $0.vals("args"))
    }

    t.rule(["functionName": .simple("name")]) {
        .call(name: try $0.str("name"), arguments: [])
    }

    t.rule(["functionName": .simple("name"), "args": .series("args")]) {
        .call(name: try $0.str("name"), arguments: try $0.vals("args"))
    }

    t.rule(["param": .simple("param")]) {
        try $0.val("param")
    }

    t.rule(["params": .series("params"), "body": .simple("body")]) {
        .subfunction(Subfunction(name: nil, patterns: try $0.vals("params"), when: .booleanValue(true), body: try $0.val("body")))
    }

    t.rule(["lambda": .simple("lambda")]) {
        try $0.val("lambda")
    }

    t.rule(["head": .simple("head"), "nameCall": .simple("call")]) {
        let head = try $0.val("head")
        guard case let .call(name, arguments) = try $0.val("call") else { throw SongTransformError.notAFunctionCall }
        return .call(name: name, arguments: [head] + arguments)
    }

    t.rule(["head": .simple("head"), "anonCall": .simple("expr")]) {
        let head = try $0.val("head")
        let expr = try $0.val("expr")
        return .callAnonymous(closure: expr, arguments: [head])
    }

    t.rule(["head": .simple("head"), "anonCall": .simple("expr"), "args": .series("args")]) {
        let head = try $0.val("head")
        let expr = try $0.val("expr")
        let args = try $0.vals("args")
        return .callAnonymous(closure: .callAnonymous(closure: expr, arguments: [head]), arguments: args)
    }

    t.rule(["anonCall": .simple("anon"), "args": .simple("args")]) {
        guard case .list(let args) = try $0.val("args") else { throw SongTransformError.unknown }
        return .callAnonymous(closure: try $0.val("anon"), arguments: args)
    }

    t.rule(["anonCall": .simple("args")]) {
        guard case .list(let args) = try $0.val("args") else { throw SongTransformError.unknown }
        let dummy = Expression.booleanValue(false)
        return .callAnonymous(closure: dummy, arguments: args)
    }

    t.rule(["nameCall": .simple("call")]) {
        try $0.val("call")
    }

    t.rule(["dotCall": .simple("call")]) {
        try $0.val("call")
    }

    t.rule(["trailCalls": .series("calls")]) {
        try reduce(try $0.vals("calls"))
    }

    t.rule(["trailCalls": .simple("call")]) {
        try $0.val("call")
    }

    t.rule(["dotCall": .series("calls")]) {
        try reduce(try $0.vals("calls"))
    }

    return t
}

func reduce(_ calls: [Expression]) throws -> Expression {
    guard calls.count > 0 else { throw SongTransformError.unknown }
    var calls = calls
    var result = calls.removeFirst()
    try calls.forEach { call in
        switch call {
        case let .callAnonymous(_, args):
            result = .callAnonymous(closure: result, arguments: args)
        case let .call(name, args):
            result = .call(name: name, arguments: [result] + args)
        default:
            throw SongTransformError.notAFunctionCall
        }
    }
    return result
}
