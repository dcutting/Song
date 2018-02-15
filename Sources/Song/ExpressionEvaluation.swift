typealias Number = Int

enum EvaluationError: Error {
    case insufficientArguments
    case notANumber(Expression)
    case notABoolean(Expression)
}

extension Expression {
    
    public func evaluate() -> Expression {
        return evaluate(context: Context())
    }
    
    public func evaluate(context: Context) -> Expression {
        switch self {

        case let .isUnit(value):
            return evaluateIsUnit(value: value, context: context)

        case let .call(name: name, arguments: arguments):
            return evaluateCall(name: name, arguments: arguments, context: context)
            
        case let .let(name, binding, body):
            return evaluateLet(name: name, binding, body, context)
            
        case let .variable(variable):
            return evaluateVariable(variable: variable, context)
            
        case .function:
            return .closure(function: self, context: context)
            
        case let .callAnonymous(closure, arguments):
            return evaluateCallAnonymous(closure: closure, arguments: arguments, callingContext: context)
            
        case let .conditional(condition, then, otherwise):
            return evaluateConditional(condition: condition, then: then, otherwise: otherwise, context: context)
            
        case let .first(pair):
            return evaluateFirst(pair: pair, context: context)
            
        case let .second(pair):
            return evaluateSecond(pair: pair, context: context)

        case let .pair(first, second):
            let evaluatedFirst = first.evaluate(context: context)
            let evaluatedSecond = second.evaluate(context: context)
            switch (evaluatedFirst, evaluatedSecond) {
            case (.error, _):
                return evaluatedFirst
            case (_, .error):
                return evaluatedSecond
            default:
                return .pair(evaluatedFirst, evaluatedSecond)
            }

        case .error, .unitValue, .booleanValue, .integerValue, .floatValue, .stringValue, .closure:
            return self
        }
    }
    
    func evaluateIsUnit(value: Expression, context: Context) -> Expression {
        if case .unitValue = value.evaluate(context: context) {
            return .booleanValue(true)
        } else {
            return .booleanValue(false)
        }
    }

    func evaluateCall(name: String, arguments: [Expression], context: Context) -> Expression {

        do {
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
                return .error("cannot evaluate call '\(name)' with arguments \(arguments)")
            }
        } catch let EvaluationError.notANumber(x) {
            return .error("\(x) is not a number")
        } catch let EvaluationError.notABoolean(x) {
            return .error("\(x) is not a boolean")
        } catch {
            preconditionFailure("internal error: \(error)")
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
            let evaluatedArg = arg.evaluate(context: context)
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
            let evaluatedArg = arg.evaluate(context: context)
            guard case let .booleanValue(n) = evaluatedArg else {
                throw EvaluationError.notABoolean(evaluatedArg)
            }
            return n
        }
    }

    func evaluatePlus(left: Expression, _ right: Expression, context: Context) -> Expression {
        let evaluatedLeft = left.evaluate(context: context)
        let evaluatedRight = right.evaluate(context: context)
        switch (evaluatedLeft, evaluatedRight) {
        case let (.integerValue(leftValue), .integerValue(rightValue)):
            return Expression.integerValue(leftValue + rightValue)
        default:
            return .error("cannot add \(evaluatedLeft) to \(evaluatedRight)")
        }
    }

    func evaluateLet(name: String, _ binding: Expression, _ body: Expression, _ context: Context) -> Expression {
        let letContext = extendContext(context: context, name: name, value: binding.evaluate(context: context))
        return body.evaluate(context: letContext)
    }
    
    func evaluateVariable(variable: String, _ context: Context) -> Expression {
        if let value = context[variable] {
            return value
        }
        return .error("cannot evaluate '\(variable)'")
    }
    
    func evaluateCallAnonymous(closure: Expression, arguments: [Expression], callingContext: Context) -> Expression {
        let evaluatedClosure = closure.evaluate(context: callingContext)
        switch evaluatedClosure {
        case let .closure(function, closureContext):
            return evaluateCallFunction(function: function, closureContext: closureContext, arguments: arguments, callingContext: callingContext, closure: evaluatedClosure)
        default:
            return .error("\(closure) is not a closure")
        }
    }
    
    func evaluateCallFunction(function: Expression, closureContext: Context, arguments: [Expression], callingContext: Context, closure: Expression) -> Expression {
        switch function {
        case let .function(name, parameters, body):
            if arguments.count < parameters.count {
                return Expression.error("not enough arguments")
            }
            if arguments.count > parameters.count {
                return Expression.error("too many arguments")
            }
            let extendedContext = extendContext(context: closureContext, parameters: parameters, arguments: arguments, callingContext: callingContext)
            var finalContext = extendedContext
            if let funcName = name {
                finalContext = extendContext(context: finalContext, name: funcName, value: closure)
            }
            return body.evaluate(context: finalContext)
        default:
            return .error("closure does not wrap function")
        }
    }
    
    func evaluateConditional(condition: Expression, then: Expression, otherwise: Expression, context: Context) -> Expression {
        switch condition.evaluate(context: context) {
        case .booleanValue(true):
            return then.evaluate(context: context)
        case .booleanValue(false):
            return otherwise.evaluate(context: context)
        default:
            return .error("boolean expression expected")
        }
    }
    
    func evaluateFirst(pair: Expression, context: Context) -> Expression {
        let evaluatedPair = pair.evaluate(context: context)
        switch evaluatedPair {
        case let .pair(fst, _):
            return fst.evaluate(context: context)
        default:
            return .error("requires pair")
        }
    }
    
    func evaluateSecond(pair: Expression, context: Context) -> Expression {
        let evaluatedPair = pair.evaluate(context: context)
        switch evaluatedPair {
        case let .pair(_, snd):
            return snd.evaluate(context: context)
        default:
            return .error("requires pair")
        }
    }
}
