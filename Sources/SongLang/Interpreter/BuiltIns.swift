import Foundation

public enum BuiltInName: Sendable, Equatable, CaseIterable {
    case equal
    case notEqual
    case not
    case and
    case or
    case number
    case string
    case character
    case scalar
    case truncate
    case sin
    case cos
    case tan
    case arcsin
    case arccos
    case arctan
    case log
    case log2
    case ln
    case power
    case plus
    case minus
    case multiply
    case divide
    case modulus
    case integerDivide
    case lessThan
    case greaterThan
    case lessThanOrEqualTo
    case greaterThanOrEqualTo
}

extension BuiltInName: CustomStringConvertible {
    public var description: String {
        keyword
    }
}

typealias BuiltInFunction = @Sendable ([SongLang.Expression], Context) throws -> SongLang.Expression

extension BuiltInName {
    var keyword: String {
        switch self {
        case .equal:
            "Eq"
        case .notEqual:
            "Neq"
        case .not:
            "Not"
        case .and:
            "And"
        case .or:
            "Or"
        case .number:
            "number"
        case .string:
            "string"
        case .character:
            "character"
        case .scalar:
            "scalar"
        case .truncate:
            "truncate"
        case .sin:
            "sin"
        case .cos:
            "cos"
        case .tan:
            "tan"
        case .arcsin:
            "arcsin"
        case .arccos:
            "arccos"
        case .arctan:
            "arctan"
        case .log:
            "log"
        case .log2:
            "log2"
        case .ln:
            "ln"
        case .power:
            "^"
        case .plus:
            "+"
        case .minus:
            "-"
        case .multiply:
            "*"
        case .divide:
            "/"
        case .modulus:
            "%"
        case .integerDivide:
            "Div"
        case .lessThan:
            "<"
        case .greaterThan:
            ">"
        case .lessThanOrEqualTo:
            "<="
        case .greaterThanOrEqualTo:
            ">="
        }
    }

    func function() -> BuiltInFunction {
        switch self {
        case .equal:
            evaluateEq
        case .notEqual:
            evaluateNeq
        case .not:
            evaluateNot
        case .and:
            evaluateAnd
        case .or:
            evaluateOr
        case .number:
            evaluateNumberConstructor
        case .string:
            evaluateStringConstructor
        case .character:
            evaluateCharacterConstructor
        case .scalar:
            evaluateScalarConstructor
        case .truncate:
            evaluateTruncateConstructor
        case .sin:
            evaluateSin
        case .cos:
            evaluateCos
        case .tan:
            evaluateTan
        case .arcsin:
            evaluateArcsin
        case .arccos:
            evaluateArccos
        case .arctan:
            evaluateArctan
        case .log:
            evaluateLog
        case .log2:
            evaluateLog2
        case .ln:
            evaluateLn
        case .power:
            evaluatePower
        case .plus:
            evaluatePlus
        case .minus:
            evaluateMinus
        case .multiply:
            evaluateMultiply
        case .divide:
            evaluateDivide
        case .modulus:
            evaluateModulus
        case .integerDivide:
            evaluateIntegerDivide
        case .lessThan:
            evaluateLessThan
        case .greaterThan:
            evaluateGreaterThan
        case .lessThanOrEqualTo:
            evaluateLessThanOrEqual
        case .greaterThanOrEqualTo:
            evaluateGreaterThanOrEqual
        }
    }
}



/* Built in function implementations. */

func evaluateEq(arguments: [Expression], context: Context) throws -> Expression {
    guard arguments.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let result: Expression
    do {
        do {
            result = try booleanOp(arguments: arguments, context: context) {
                .bool($0 == $1)
            }
        } catch EvaluationError.notABoolean {
            do {
                result = try numberOp(arguments: arguments, context: context) {
                    try .bool($0.equalTo($1))
                }
            } catch EvaluationError.notANumber {
                do {
                    result = try characterOp(arguments: arguments, context: context) {
                        .bool($0 == $1)
                    }
                } catch EvaluationError.notACharacter {
                    result = try listOp(arguments: arguments, context: context) { left, right in
                        guard left.count == right.count else { return .no }
                        for (l, r) in zip(left, right) {
                            let lrEq = try evaluateEq(arguments: [l, r], context: context)
                            if case .no = lrEq {
                                return .no
                            }
                        }
                        return .yes
                    }
                    // TODO: need proper equality check for listCons too.
                }
            }
        }
    } catch {
        throw EvaluationError.cannotCompare(arguments[0], arguments[1])
    }
    return result
}

func evaluateNeq(arguments: [Expression], context: Context) throws -> Expression {
    let equal = try evaluateEq(arguments: arguments, context: context)
    return try evaluateNot(arguments: [equal], context: context)
}

func evaluateNot(arguments: [Expression], context: Context) throws -> Expression {
    var bools = try toBools(arguments: arguments, context: context)
    guard bools.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = bools.removeFirst()
    return .bool(!left)
}

func evaluateAnd(arguments: [Expression], context: Context) throws -> Expression {
    var bools = try toBools(arguments: arguments, context: context)
    guard bools.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = bools.removeFirst()
    let right = bools.removeFirst()
    return .bool(left && right)
}

func evaluateOr(arguments: [Expression], context: Context) throws -> Expression {
    var bools = try toBools(arguments: arguments, context: context)
    guard bools.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = bools.removeFirst()
    let right = bools.removeFirst()
    return .bool(left || right)
}

func evaluateNumberConstructor(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = arguments
    guard numbers.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let result: Expression
    do {
        let string = try left.evaluate(context: context).toString()
        let number = try Number.convert(from: string)
        result = .number(number)
    } catch EvaluationError.numericMismatch {
        throw EvaluationError.notANumber(left)
    }
    return result
}

func evaluateStringConstructor(arguments: [Expression], context: Context) throws -> Expression {
    let output = try arguments.formattedString(context: context)
    return .string(output)
}

func evaluateCharacterConstructor(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    switch left {
    case .int(let value):
        guard let scalar = UnicodeScalar(value as Int) else { throw EvaluationError.numericMismatch }
        return .char(Character(scalar))
    default:
        throw EvaluationError.numericMismatch
    }
}

func evaluateScalarConstructor(arguments: [Expression], context: Context) throws -> Expression {
    guard arguments.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
    var chars = try toCharacters(arguments: arguments, context: context)
    let left = chars.removeFirst()
    let string = String(left)
    guard let value = UnicodeScalar(string)?.value else { throw EvaluationError.notACharacter(arguments[0]) }
    return .int(IntType(value))
}

func evaluateTruncateConstructor(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    return .number(left.truncate())
}

func evaluateSin(arguments: [Expression], context: Context) throws -> Expression {
    try evaluateUnaryNumericOp(arguments: arguments, context: context, op: sin)
}

func evaluateCos(arguments: [Expression], context: Context) throws -> Expression {
    try evaluateUnaryNumericOp(arguments: arguments, context: context, op: cos)
}

func evaluateTan(arguments: [Expression], context: Context) throws -> Expression {
    try evaluateUnaryNumericOp(arguments: arguments, context: context, op: tan)
}

func evaluateArcsin(arguments: [Expression], context: Context) throws -> Expression {
    try evaluateUnaryNumericOp(arguments: arguments, context: context, op: asin)
}

func evaluateArccos(arguments: [Expression], context: Context) throws -> Expression {
    try evaluateUnaryNumericOp(arguments: arguments, context: context, op: acos)
}

func evaluateArctan(arguments: [Expression], context: Context) throws -> Expression {
    try evaluateUnaryNumericOp(arguments: arguments, context: context, op: atan)
}

func evaluateLog(arguments: [Expression], context: Context) throws -> Expression {
    try evaluateUnaryNumericOp(arguments: arguments, context: context, op: log10)
}

func evaluateLog2(arguments: [Expression], context: Context) throws -> Expression {
    try evaluateUnaryNumericOp(arguments: arguments, context: context, op: log2)
}

func evaluateLn(arguments: [Expression], context: Context) throws -> Expression {
    try evaluateUnaryNumericOp(arguments: arguments, context: context, op: log)
}

func evaluatePower(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(left.power(right))
}

func evaluatePlus(arguments: [Expression], context: Context) throws -> Expression {
    guard arguments.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let result: Expression
    do {
        result = try numberOp(arguments: arguments, context: context) {
            .number($0.plus($1))
        }
    } catch EvaluationError.notANumber {
        result = try listOp(arguments: arguments, context: context) {
            .list($0 + $1)
        }
    }
    return result
}

func evaluateMinus(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    let result: Expression
    if numbers.count == 1 {
        let right = numbers.removeFirst()
        result = .number(right.negate())
    } else if numbers.count == 2 {
        let left = numbers.removeFirst()
        let right = numbers.removeFirst()
        result = .number(left.minus(right))
    } else {
        throw EvaluationError.signatureMismatch(arguments)
    }
    return result
}

func evaluateMultiply(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(left.times(right))
}

func evaluateDivide(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(try left.floatDividedBy(right))
}

func evaluateModulus(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(try left.modulo(right))
}

func evaluateIntegerDivide(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(try left.integerDividedBy(right))
}

func evaluateLessThan(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .bool(left.lessThan(right))
}

func evaluateGreaterThan(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .bool(left.greaterThan(right))
}

func evaluateLessThanOrEqual(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .bool(left.lessThanOrEqualTo(right))
}

func evaluateGreaterThanOrEqual(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .bool(left.greaterThanOrEqualTo(right))
}



/* Helpers. */

private func evaluateUnaryNumericOp(arguments: [Expression], context: Context, op: (FloatType) -> FloatType) throws -> Expression {
    guard arguments.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
    var numbers = try toNumbers(arguments: arguments, context: context)
    let argument = numbers.removeFirst()
    let float = switch argument {
    case .int(let value):
        FloatType(value)
    case .float(let value):
        value
    }
    return .number(.float(op(float)))
}

private func extractNumber(_ expression: Expression, context: Context) throws -> Number {
    if case .number(let number) = try expression.evaluate(context: context) {
        return number
    }
    throw EvaluationError.notANumber(expression)
}

private func extractBool(_ expression: Expression, context: Context) throws -> Bool {
    if case .bool(let value) = try expression.evaluate(context: context) {
        return value
    }
    throw EvaluationError.notABoolean(expression)
}

private func extractCharacter(_ expression: Expression, context: Context) throws -> Character {
    if case .char(let value) = try expression.evaluate(context: context) {
        return value
    }
    throw EvaluationError.notACharacter(expression)
}

private func extractList(_ expression: Expression, context: Context) throws -> [Expression] {
    if case .list(let list) = try expression.evaluate(context: context) {
        return list
    }
    throw EvaluationError.notAList(expression)
}

private func toNumbers(arguments: [Expression], context: Context) throws -> [Number] {
    return try arguments.map { arg -> Number in
        let evaluatedArg = try arg.evaluate(context: context)
        guard case let .number(n) = evaluatedArg else {
            throw EvaluationError.notANumber(evaluatedArg)
        }
        return n
    }
}

private func toCharacters(arguments: [Expression], context: Context) throws -> [Character] {
    return try arguments.map { arg -> Character in
        let evaluatedArg = try arg.evaluate(context: context)
        guard case let .char(n) = evaluatedArg else {
            throw EvaluationError.notACharacter(evaluatedArg)
        }
        return n
    }
}

private func toBools(arguments: [Expression], context: Context) throws -> [Bool] {
    return try arguments.map { arg -> Bool in
        let evaluatedArg = try arg.evaluate(context: context)
        guard case let .bool(n) = evaluatedArg else {
            throw EvaluationError.notABoolean(evaluatedArg)
        }
        return n
    }
}

private func numberOp(arguments: [Expression], context: Context, callback: (Number, Number) throws -> Expression) throws -> Expression {
    var numbers = arguments
    let left = try extractNumber(numbers.removeFirst(), context: context)
    let right = try extractNumber(numbers.removeFirst(), context: context)
    return try callback(left, right)
}

private func booleanOp(arguments: [Expression], context: Context, callback: (Bool, Bool) throws -> Expression) throws -> Expression {
    var bools = arguments
    let left = try extractBool(bools.removeFirst(), context: context)
    let right = try extractBool(bools.removeFirst(), context: context)
    return try callback(left, right)
}

private func characterOp(arguments: [Expression], context: Context, callback: (Character, Character) throws -> Expression) throws -> Expression {
    var chars = arguments
    let left = try extractCharacter(chars.removeFirst(), context: context)
    let right = try extractCharacter(chars.removeFirst(), context: context)
    return try callback(left, right)
}

private func listOp(arguments: [Expression], context: Context, callback: ([Expression], [Expression]) throws -> Expression) throws -> Expression {
    var lists = arguments
    let left = try extractList(lists.removeFirst(), context: context)
    let right = try extractList(lists.removeFirst(), context: context)
    return try callback(left, right)
}
