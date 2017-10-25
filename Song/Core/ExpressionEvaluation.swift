extension Expression {
    
    public func evaluate() -> Expression {
        return evaluate(context: Context())
    }
    
    public func evaluate(context: Context) -> Expression {
        switch self {
            
        case let .isUnit(value):
            return evaluateIsUnit(value: value, context: context)
            
        case let .plus(left, right):
            return evaluatePlus(left: left, right, context: context)
            
        case let .let(name, binding, body):
            return evaluateLet(name: name, binding, body, context)
            
        case let .variable(variable):
            return evaluateVariable(variable: variable, context)
            
        case .function:
            return .closure(function: self, context: context)
            
        case let .call(closure, arguments):
            return evaluateCallClosure(closure: closure, arguments: arguments, callingContext: context)
            
        case let .conditional(condition, then, otherwise):
            return evaluateConditional(condition: condition, then: then, otherwise: otherwise, context: context)
            
        case let .first(pair):
            return evaluateFirst(pair: pair, context: context)
            
        case let .second(pair):
            return evaluateSecond(pair: pair, context: context)
            
        default:
            return self
        }
    }
    
    func evaluateIsUnit(value: Expression, context: Context) -> Expression {
        switch value.evaluate(context: context) {
        case .unitValue:
            return .booleanValue(true)
        default:
            return .booleanValue(false)
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
        return .error("cannot evaluate \(variable)")
    }
    
    func evaluateCallClosure(closure: Expression, arguments: [Expression], callingContext: Context) -> Expression {
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
