func evaluateEq(arguments: [Expression], context: Context) throws -> Expression {
    guard arguments.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let result: Expression
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
                // TODO: need propr equality check for listCons too.
            }
        }
    }
    return result
}

func evaluateNeq(arguments: [Expression], context: Context) throws -> Expression {
    let equalCall = Expression.call("Eq", arguments)
    let notCall = Expression.call("Not", [equalCall])
    return try notCall.evaluate(context: context)
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
    do {
        let string = try left.evaluate(context: context).asString()
        let number = try Number.convert(from: string)
        return Expression.number(number)
    } catch EvaluationError.numericMismatch {
        throw EvaluationError.notANumber(left)
    }
}

func evaluateStringConstructor(arguments: [Expression], context: Context) throws -> Expression {
    let output = try prepareOutput(for: arguments, context: context)
    return .string(output)
}

func evaluateTruncateConstructor(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    return .number(left.truncate())
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
    if numbers.count == 1 {
        let right = numbers.removeFirst()
        return .number(right.negate())
    } else if numbers.count == 2 {
        let left = numbers.removeFirst()
        let right = numbers.removeFirst()
        return .number(left.minus(right))
    } else {
        throw EvaluationError.signatureMismatch(arguments)
    }
}

func evaluateTimes(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(left.times(right))
}

func evaluateDividedBy(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(left.floatDividedBy(right))
}

func evaluateMod(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(try left.modulo(right))
}

func evaluateDiv(arguments: [Expression], context: Context) throws -> Expression {
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

func evaluateIn(arguments: [Expression], context: Context) throws -> Expression {
    let evaluated = try arguments.map { expr -> Expression in try expr.evaluate(context: context) }
    let output = evaluated.map { $0.out() }.joined(separator: " ")
    _stdOut.put(output)
    let line = _stdIn.get() ?? ""
    return .string(line)
}

func evaluateOut(arguments: [Expression], context: Context) throws -> Expression {
    let output = try prepareOutput(for: arguments, context: context)
    _stdOut.put(output + "\n")
    return .string(output)
}

func evaluateErr(arguments: [Expression], context: Context) throws -> Expression {
    let output = try prepareOutput(for: arguments, context: context)
    _stdErr.put(output + "\n")
    return .string(output)
}



/* Helpers. */

private func prepareOutput(for arguments: [Expression], context: Context) throws -> String {
    let evaluated = try arguments.map { expr -> Expression in try expr.evaluate(context: context) }
    return evaluated.map { $0.out() }.joined(separator: " ")
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
    throw EvaluationError.notACharacter
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
