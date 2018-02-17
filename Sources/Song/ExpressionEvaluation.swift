typealias Number = Int

public enum EvaluationError: Error {
    case insufficientArguments
    case tooManyArguments
    case notAPair(Expression)
    case notANumber(Expression)
    case notABoolean(Expression)
    case notAFunction(Expression)
    case symbolNotFound(String)
}

extension Expression {
    
    public func evaluate() throws -> Expression {
        return try evaluate(context: Context())
    }
    
    public func evaluate(context: Context) throws -> Expression {
        switch self {

        case let .isUnit(value):
            return try evaluateIsUnit(value: value, context: context)

        case let .call(name: name, arguments: arguments):
            return try evaluateCall(name: name, arguments: arguments, context: context)
            
        case let .let(name, binding, body):
            return try evaluateLet(name: name, binding, body, context)
            
        case let .variable(variable):
            return try evaluateVariable(variable: variable, context)
            
        case let .callAnonymous(subfunction, arguments):
            return try evaluateSubfunctionCall(expression: subfunction, arguments: arguments, callingContext: context)
            
        case let .conditional(condition, then, otherwise):
            return try evaluateConditional(condition: condition, then: then, otherwise: otherwise, context: context)
            
        case let .first(pair):
            return try evaluateFirst(pair: pair, context: context)
            
        case let .second(pair):
            return try evaluateSecond(pair: pair, context: context)

        case let .pair(first, second):
            let evaluatedFirst = try first.evaluate(context: context)
            let evaluatedSecond = try second.evaluate(context: context)
            return .pair(evaluatedFirst, evaluatedSecond)

        case .unitValue, .booleanValue, .integerValue, .floatValue, .stringValue, .subfunction:
            return self
        }
    }
    
    func evaluateIsUnit(value: Expression, context: Context) throws -> Expression {
        if case .unitValue = try value.evaluate(context: context) {
            return .booleanValue(true)
        } else {
            return .booleanValue(false)
        }
    }

    func evaluateCall(name: String, arguments: [Expression], context: Context) throws -> Expression {

        switch name {
        case "*":
            let numbers = try toNumbers(arguments: arguments, context: context)
            let result = numbers.reduce(1) { a, n in a * n }
            return Expression.integerValue(result)
        case "/":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count > 0 else { throw EvaluationError.insufficientArguments }
            let first = numbers.removeFirst()
            let result = numbers.reduce(first) { a, n in a / n }
            return Expression.integerValue(result)
        case "%":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count > 0 else { throw EvaluationError.insufficientArguments }
            let first = numbers.removeFirst()
            let result = numbers.reduce(first) { a, n in a % n }
            return Expression.integerValue(result)
        case "+":
            let numbers = try toNumbers(arguments: arguments, context: context)
            let result = numbers.reduce(0) { a, n in a + n }
            return Expression.integerValue(result)
        case "-":
            let numbers = try toNumbers(arguments: arguments, context: context)
            let normalisedNumbers = numbers.enumerated().map { (i, n) in
                return i > 0 ? -n : n
            }
            let result = normalisedNumbers.reduce(0) { a, n in a + n }
            return Expression.integerValue(result)
        case "<":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a < b }
        case ">":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a > b }
        case "<=":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a <= b }
        case ">=":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a >= b }
        case "=":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a == b }
        case "<>":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a != b }
        case "&":
            return try evaluateLogical(arguments: arguments, context: context) { a, b in a && b }
        case "|":
            return try evaluateLogical(arguments: arguments, context: context) { a, b in a || b }
        default:
            return try evaluateUserFunction(name: name, arguments: arguments, context: context)
        }
    }

    private func evaluateRelational(arguments: [Expression], context: Context, callback: (Number, Number) -> Bool) throws -> Expression {
        var numbers = try toNumbers(arguments: arguments, context: context)
        guard numbers.count > 0 else { throw EvaluationError.insufficientArguments }
        let first = numbers.removeFirst()
        let (result, _) = numbers.reduce((true, first)) { a, n in
            let (v, x) = a
            return (v && callback(x, n), n)
        }
        return Expression.booleanValue(result)
    }

    private func toNumbers(arguments: [Expression], context: Context) throws -> [Number] {
        return try arguments.map { arg -> Number in
            let evaluatedArg = try arg.evaluate(context: context)
            guard case let .integerValue(n) = evaluatedArg else {
                throw EvaluationError.notANumber(evaluatedArg)
            }
            return Number(n)
        }
    }

    private func evaluateLogical(arguments: [Expression], context: Context, callback: (Bool, Bool) -> Bool) throws -> Expression {
        var bools = try toBools(arguments: arguments, context: context)
        guard bools.count > 0 else { throw EvaluationError.insufficientArguments }
        let first = bools.removeFirst()
        let (result, _) = bools.reduce((true, first)) { a, n in
            let (v, x) = a
            return (v && callback(x, n), n)
        }
        return Expression.booleanValue(result)
    }

    private func toBools(arguments: [Expression], context: Context) throws -> [Bool] {
        return try arguments.map { arg -> Bool in
            let evaluatedArg = try arg.evaluate(context: context)
            guard case let .booleanValue(n) = evaluatedArg else {
                throw EvaluationError.notABoolean(evaluatedArg)
            }
            return n
        }
    }

    func evaluateLet(name: String, _ binding: Expression, _ body: Expression, _ context: Context) throws -> Expression {
        let letContext = extendContext(context: context, name: name, value: try binding.evaluate(context: context))
        return try body.evaluate(context: letContext)
    }
    
    func evaluateVariable(variable: String, _ context: Context) throws -> Expression {
        if let value = context[variable] {
            return value
        }
        throw EvaluationError.symbolNotFound(variable)
    }
    
    func evaluateSubfunctionCall(expression: Expression, arguments: [Expression], callingContext: Context) throws -> Expression {
        let evaluated = try expression.evaluate(context: callingContext)
        switch evaluated {
        case let .subfunction(subfunction):
            let body = subfunction.body
            let finalContext = try extendContext(context: Context(), parameters: subfunction.patterns, arguments: arguments, callingContext: callingContext)
            return try body.evaluate(context: finalContext)
        default:
            throw EvaluationError.notAFunction(expression)
        }
    }
    
    func evaluateCallFunction(function: Expression, closureContext: Context, arguments: [Expression], callingContext: Context, closure: Expression) throws -> Expression {
        switch function {
        case let .subfunction(subfunction):

            if arguments.count < subfunction.patterns.count {
                throw EvaluationError.insufficientArguments
            }
            if arguments.count > subfunction.patterns.count {
                throw EvaluationError.tooManyArguments
            }
            let extendedContext = try extendContext(context: closureContext, parameters: subfunction.patterns, arguments: arguments, callingContext: callingContext)
            var finalContext = extendedContext
            if let funcName = subfunction.name {
                finalContext = extendContext(context: finalContext, name: funcName, value: closure)
            }
            return try subfunction.body.evaluate(context: finalContext)
        case let .call(name, arguments):
            let finalContext = callingContext.merging(closureContext) { l, r in l }
            return try evaluateCall(name: name, arguments: arguments, context: finalContext)
        default:
            throw EvaluationError.notAFunction(closure)
        }
    }
    
    func evaluateConditional(condition: Expression, then: Expression, otherwise: Expression, context: Context) throws -> Expression {
        switch try condition.evaluate(context: context) {
        case .booleanValue(true):
            return try then.evaluate(context: context)
        case .booleanValue(false):
            return try otherwise.evaluate(context: context)
        default:
            throw EvaluationError.notABoolean(condition)
        }
    }
    
    func evaluateFirst(pair: Expression, context: Context) throws -> Expression {
        let evaluatedPair = try pair.evaluate(context: context)
        switch evaluatedPair {
        case let .pair(fst, _):
            return try fst.evaluate(context: context)
        default:
             throw EvaluationError.notAPair(pair)
        }
    }
    
    func evaluateSecond(pair: Expression, context: Context) throws -> Expression {
        let evaluatedPair = try pair.evaluate(context: context)
        switch evaluatedPair {
        case let .pair(_, snd):
            return try snd.evaluate(context: context)
        default:
            throw EvaluationError.notAPair(pair)
        }
    }

    private func evaluateUserFunction(name: String, arguments: [Expression], context: Context) throws -> Expression {
        guard let expr = context[name] else {
            throw EvaluationError.symbolNotFound(name)
        }
        return try evaluateSubfunctionCall(expression: expr, arguments: arguments, callingContext: context)
    }
}
