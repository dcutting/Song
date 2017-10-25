extension Expression {
    
    public func evaluate() -> Expression {
        return evaluate(context: Context())
    }
    
    public func evaluate(context: Context) -> Expression {
        switch self {
            
        case let .IsUnit(value):
            return evaluateIsUnit(value: value, context: context)
            
        case let .Plus(left, right):
            return evaluatePlus(left: left, right, context: context)
            
        case let .Let(name, binding, body):
            return evaluateLet(name: name, binding, body, context)
            
        case let .Variable(variable):
            return evaluateVariable(variable: variable, context)
            
        case .Function:
            return .Closure(function: self, context: context)
            
        case let .Call(closure, arguments):
            return evaluateCallClosure(closure: closure, arguments: arguments, callingContext: context)
            
        case let .Conditional(condition, then, otherwise):
            return evaluateConditional(condition: condition, then: then, otherwise: otherwise, context: context)
            
        case let .First(pair):
            return evaluateFirst(pair: pair, context: context)
            
        case let .Second(pair):
            return evaluateSecond(pair: pair, context: context)
            
        default:
            return self
        }
    }
    
    func evaluateIsUnit(value: Expression, context: Context) -> Expression {
        switch value.evaluate(context: context) {
        case .UnitValue:
            return .BooleanValue(true)
        default:
            return .BooleanValue(false)
        }
    }
    
    func evaluatePlus(left: Expression, _ right: Expression, context: Context) -> Expression {
        let evaluatedLeft = left.evaluate(context: context)
        let evaluatedRight = right.evaluate(context: context)
        switch (evaluatedLeft, evaluatedRight) {
        case let (.IntegerValue(leftValue), .IntegerValue(rightValue)):
            return Expression.IntegerValue(leftValue + rightValue)
        default:
            return .Error("cannot add \(evaluatedLeft) to \(evaluatedRight)")
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
        return .Error("cannot evaluate \(variable)")
    }
    
    func evaluateCallClosure(closure: Expression, arguments: [Expression], callingContext: Context) -> Expression {
        let evaluatedClosure = closure.evaluate(context: callingContext)
        switch evaluatedClosure {
        case let .Closure(function, closureContext):
            return evaluateCallFunction(function: function, closureContext: closureContext, arguments: arguments, callingContext: callingContext, closure: evaluatedClosure)
        default:
            return .Error("\(closure) is not a closure")
        }
    }
    
    func evaluateCallFunction(function: Expression, closureContext: Context, arguments: [Expression], callingContext: Context, closure: Expression) -> Expression {
        switch function {
        case let .Function(name, parameters, body):
            if arguments.count < parameters.count {
                return Expression.Error("not enough arguments")
            }
            if arguments.count > parameters.count {
                return Expression.Error("too many arguments")
            }
            let extendedContext = extendContext(context: closureContext, parameters: parameters, arguments: arguments, callingContext: callingContext)
            var finalContext = extendedContext
            if let funcName = name {
                finalContext = extendContext(context: finalContext, name: funcName, value: closure)
            }
            return body.evaluate(context: finalContext)
        default:
            return .Error("closure does not wrap function")
        }
    }
    
    func evaluateConditional(condition: Expression, then: Expression, otherwise: Expression, context: Context) -> Expression {
        switch condition.evaluate(context: context) {
        case .BooleanValue(true):
            return then.evaluate(context: context)
        case .BooleanValue(false):
            return otherwise.evaluate(context: context)
        default:
            return .Error("boolean expression expected")
        }
    }
    
    func evaluateFirst(pair: Expression, context: Context) -> Expression {
        let evaluatedPair = pair.evaluate(context: context)
        switch evaluatedPair {
        case let .Pair(fst, _):
            return fst.evaluate(context: context)
        default:
            return .Error("requires pair")
        }
    }
    
    func evaluateSecond(pair: Expression, context: Context) -> Expression {
        let evaluatedPair = pair.evaluate(context: context)
        switch evaluatedPair {
        case let .Pair(_, snd):
            return snd.evaluate(context: context)
        default:
            return .Error("requires pair")
        }
    }
}
