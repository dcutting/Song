typealias Number = Int

public enum EvaluationError: Error {
    case insufficientArguments
    case tooManyArguments
    case notAPair(Expression)
    case notANumber(Expression)
    case notABoolean(Expression)
    case notAFunction(Expression)
    case symbolNotFound(String)
    case signatureMismatch
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

        case let .constant(name, value):
            return .constant(name: name, value: try value.evaluate(context: context))

        case let .subfunction(subfunction):
            var finalContext = context
            if let name = subfunction.name {
                finalContext.removeValue(forKey: name)
            }
            return .closure(closure: self, context: finalContext)

        case let .callAnonymous(subfunction, arguments):
            return try evaluateCallAnonymous(closure: subfunction, arguments: arguments, callingContext: context)
            
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

        case .unitValue, .booleanValue, .integerValue, .floatValue, .stringValue, .closure:
            return self
        }
    }
    
    func evaluateIsUnit(value: Expression, context: Context) throws -> Expression {
        if case .unitValue = try value.evaluate(context: context) {
            return .booleanValue(true)
        }
        return .booleanValue(false)
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
        case "eq":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a == b }
        case "neq":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a != b }
        case "&":
            return try evaluateLogical(arguments: arguments, context: context) { a, b in a && b }
        case "|":
            return try evaluateLogical(arguments: arguments, context: context) { a, b in a || b }
        case "out":
            return try evaluateOut(arguments: arguments, context: context)
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
        let letContext = extendContext(context: context, name: name, value: try binding.evaluate(context: context), replacing: true)
        return try body.evaluate(context: letContext)
    }
    
    func evaluateVariable(variable: String, _ context: Context) throws -> Expression {
        guard
            let values = context[variable],
            let value = values.first
            else { throw EvaluationError.symbolNotFound(variable) }
        return value
    }
    
    func evaluateCallAnonymous(closure: Expression, arguments: [Expression], callingContext: Context) throws -> Expression {
        let evaluatedClosure = try closure.evaluate(context: callingContext)
        switch evaluatedClosure {
        case let .closure(function, closureContext):
            return try evaluateCallFunction(function: function, closureContext: closureContext, arguments: arguments, callingContext: callingContext, closure: evaluatedClosure)
        default:
            throw EvaluationError.notAFunction(closure)
        }
    }
    
    func evaluateCallFunction(function: Expression, closureContext: Context, arguments: [Expression], callingContext: Context, closure: Expression) throws -> Expression {
        switch function {
        case let .subfunction(subfunction):

            var extendedContext = try matchParameters(closureContext: closureContext, callingContext: callingContext, parameters: subfunction.patterns, arguments: arguments)
            let whenEvaluated = try subfunction.when.evaluate(context: extendedContext)
            guard case .booleanValue(true) = whenEvaluated else { throw EvaluationError.signatureMismatch }
            if let funcName = subfunction.name {
                extendedContext = extendContext(context: extendedContext, name: funcName, value: closure, replacing: false)
            }
            return try subfunction.body.evaluate(context: extendedContext)
        default:
            throw EvaluationError.notAFunction(closure)
        }
    }

    private func matchParameters(closureContext: Context, callingContext: Context, parameters: [Expression], arguments: [Expression]) throws -> Context {
        guard parameters.count <= arguments.count else { throw EvaluationError.insufficientArguments }
        guard arguments.count <= parameters.count else { throw EvaluationError.tooManyArguments }

        var extendedContext = closureContext
        for (p, a) in zip(parameters, arguments) {
            extendedContext = try matchAndExtend(context: extendedContext, parameter: p, argument: a, callingContext: callingContext)
        }
        return extendedContext
    }

    private func matchAndExtend(context: Context, parameter: Expression, argument: Expression, callingContext: Context) throws -> Context {
        var extendedContext = context
        switch parameter {
        case .variable(let name):
            let evaluatedValue = try argument.evaluate(context: callingContext)
            extendedContext = extendContext(context: extendedContext, name: name, value: evaluatedValue, replacing: true)
        default:
            throw EvaluationError.signatureMismatch
        }
        return extendedContext
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

    private func evaluateOut(arguments: [Expression], context: Context) throws -> Expression {
        let evaluated = try arguments.map { expr -> Expression in try expr.evaluate(context: context) }
        let output = evaluated.map { $0.out() }.joined(separator: " ")
        print(output)
        return Expression.unitValue
    }

    private func evaluateUserFunction(name: String, arguments: [Expression], context: Context) throws -> Expression {
        guard
            let exprs = context[name]
            else { throw EvaluationError.symbolNotFound(name) }
        for expr in exprs {
            do {
                return try evaluateCallAnonymous(closure: expr, arguments: arguments, callingContext: context)
            } catch EvaluationError.signatureMismatch {}
        }
        throw EvaluationError.signatureMismatch
    }
}
