public protocol ExpressionLike {}

public enum Expression: ExpressionLike, Equatable, Printable {

    
    case Error(String)
    
    case UnitValue

    case BooleanValue(Bool)
    
    case IntegerValue(Int)
    
    case StringValue(String)
    
    case IsUnit(ExpressionLike)
    
    case Plus(ExpressionLike, ExpressionLike)
    
    case Pair(ExpressionLike, ExpressionLike)
    
    case First(ExpressionLike)
    
    case Second(ExpressionLike)
    
    case Closure(function: ExpressionLike, context: Context)
    
    case Let(name: String, binding: ExpressionLike, body: ExpressionLike)
    
    case Variable(String)
    
    case Function(name: String?, parameters: [String], body: ExpressionLike)
    
    case Call(closure: ExpressionLike, arguments: [ExpressionLike])
    
    case Conditional(condition: ExpressionLike, then: ExpressionLike, otherwise: ExpressionLike)
    
    
    public var description: String {
        switch self {
            
        case let .Error(value):
            return "<\(value)>"

        case .UnitValue:
            return "#"

        case let .BooleanValue(value):
            return value ? "yes" : "no"
            
        case let .IntegerValue(value):
            return "\(value)"
            
        case let .StringValue(value):
            return "'\(value)'"
            
        case let .IsUnit(value):
            return "isUnitValue(\(value))"
            
        case let .Plus(left, right):
            return "\(left) + \(right)"
            
        case let .Pair(first as Expression, second as Expression):
            return "(\(first), \(second))"
            
        case let .First(value):
            return "first(\(value))"
            
        case let .Second(value):
            return "second(\(value))"
        
        case let .Closure(function as Expression, context):
            let contextList = contextDescription(context)
            return "[(\(contextList)) \(function)]"

        case let .Let(name, binding as Expression, body as Expression):
            return "let (\(name) = \(binding)) { \(body) }"
        
        case let .Variable(variable):
            return "\(variable)"
            
        case let .Function(name, parameters, body as Expression):
            return descriptionFunction(name, parameters, body)
            
        case let .Call(closure as Expression, arguments):
            return descriptionCall(closure, arguments: arguments)
            
        case let .Conditional(condition as Expression, then as Expression, otherwise as Expression):
            return "if \(condition) then \(then) else \(otherwise) end"
        
        default:
            return "<unknown>"
        }
    }
    
    func descriptionFunction(name: String?, _ parameters: [String], _ body: Expression) -> String {
        let parametersList = ", ".join(parameters)
        if let funcName = name {
            return "def \(funcName)(\(parametersList)) { \(body) }"
        } else {
            return "λ(\(parametersList)) { \(body) }"
        }
    }
    
    func descriptionCall(closure: Expression, arguments: [ExpressionLike]) -> String {
        var argumentStrings = Array<String>()
        for arg in arguments {
            argumentStrings.append("\(arg as Expression)")
        }
        let argumentsList = ", ".join(argumentStrings)
        return "\(closure)(\(argumentsList))"
    }
    
    public func evaluate() -> Expression {
        return evaluate(Context())
    }
    
    public func evaluate(context: Context) -> Expression {
        switch self {

        case let .IsUnit(value as Expression):
            return evaluateIsUnit(value, context: context)
            
        case let .Plus(left as Expression, right as Expression):
            return evaluatePlus(left, right, context: context)
            
        case let .Let(name, binding as Expression, body as Expression):
            return evaluateLet(name, binding, body, context)
            
        case let .Variable(variable):
            return evaluateVariable(variable, context)

        case let .Function:
            return Closure(function: self, context: context)
            
        case let .Call(closure as Expression, arguments):
            return evaluateCallClosure(closure, arguments: arguments, callingContext: context)

        case let .Conditional(condition as Expression, then as Expression, otherwise as Expression):
            return evaluateConditional(condition, then: then, otherwise: otherwise, context: context)
            
        case let .First(pair as Expression):
            return evaluateFirst(pair, context: context)
            
        case let .Second(pair as Expression):
            return evaluateSecond(pair, context: context)
            
        default:
            return self
        }
    }

    func evaluateIsUnit(value: Expression, context: Context) -> Expression {
        switch value.evaluate(context) {
        case .UnitValue:
            return BooleanValue(true)
        default:
            return BooleanValue(false)
        }
    }
    
    func evaluatePlus(left: Expression, _ right: Expression, context: Context) -> Expression {
        let evaluatedLeft = left.evaluate(context)
        let evaluatedRight = right.evaluate(context)
        switch (evaluatedLeft, evaluatedRight) {
        case let (.IntegerValue(leftValue), .IntegerValue(rightValue)):
            return Expression.IntegerValue(leftValue + rightValue)
        default:
            return Error("cannot add \(evaluatedLeft) to \(evaluatedRight)")
        }
    }
    
    func evaluateLet(name: String, _ binding: Expression, _ body: Expression, _ context: Context) -> Expression {
        let letContext = extendContext(context, name: name, value: binding.evaluate(context))
        return body.evaluate(letContext)
    }
    
    func evaluateVariable(variable: String, _ context: Context) -> Expression {
        if let value = context[variable] {
            return value
        }
        return Error("cannot evaluate \(variable)")
    }
    
    func evaluateCallClosure(closure: Expression, arguments: [ExpressionLike], callingContext: Context) -> Expression {
        let evaluatedClosure = closure.evaluate(callingContext)
        switch evaluatedClosure {
        case let .Closure(function as Expression, closureContext):
            return evaluateCallFunction(function, closureContext: closureContext, arguments: arguments, callingContext: callingContext, closure: evaluatedClosure)
        default:
            return Error("\(closure) is not a closure")
        }
    }
    
    func evaluateCallFunction(function: Expression, closureContext: Context, arguments: [ExpressionLike], callingContext: Context, closure: Expression) -> Expression {
        switch function {
        case let .Function(name, parameters, body as Expression):
            if arguments.count < parameters.count {
                return Expression.Error("not enough arguments")
            }
            if arguments.count > parameters.count {
                return Expression.Error("too many arguments")
            }
            let extendedContext = extendContext(closureContext, parameters: parameters, arguments: arguments, callingContext: callingContext)
            var finalContext = extendedContext
            if let funcName = name {
                finalContext = extendContext(finalContext, name: funcName, value: closure)
            }
            return body.evaluate(finalContext)
        default:
            return Error("closure does not wrap function")
        }
    }
    
    func evaluateConditional(condition: Expression, then: Expression, otherwise: Expression, context: Context) -> Expression {
        switch condition.evaluate(context) {
        case .BooleanValue(true):
            return then.evaluate(context)
        case .BooleanValue(false):
            return otherwise.evaluate(context)
        default:
            return Error("boolean expression expected")
        }
    }
    
    func evaluateFirst(pair: Expression, context: Context) -> Expression {
        let evaluatedPair = pair.evaluate(context)
        switch evaluatedPair {
        case let Pair(fst as Expression, _ as Expression):
            return fst.evaluate(context)
        default:
            return Error("requires pair")
        }
    }
    
    func evaluateSecond(pair: Expression, context: Context) -> Expression {
        let evaluatedPair = pair.evaluate(context)
        switch evaluatedPair {
        case let Pair(_ as Expression, snd as Expression):
            return snd.evaluate(context)
        default:
            return Error("requires pair")
        }
    }
}

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
        
    case let (.Error(lhsError), .Error(rhsError)):
        return lhsError == rhsError

    case (.UnitValue, .UnitValue):
        return true
        
    case let (.BooleanValue(lhsValue), .BooleanValue(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.IntegerValue(lhsValue), .IntegerValue(rhsValue)):
        return lhsValue == rhsValue
    
    case let (.StringValue(lhsValue), .StringValue(rhsValue)):
        return lhsValue == rhsValue
    
    case let (.Pair(lhsFirst as Expression, lhsSecond as Expression),
        .Pair(rhsFirst as Expression, rhsSecond as Expression)):
        return lhsFirst == rhsFirst && lhsSecond == rhsSecond
    
    case let (.Closure(lhsFunction as Expression, lhsContext), .Closure(rhsFunction as Expression, rhsContext)):
        return lhsFunction == rhsFunction && lhsContext == rhsContext
        
    case let (.Variable(lhsVariable), .Variable(rhsVariable)):
        return lhsVariable == rhsVariable
    
    case let (.Function(lhsName, lhsParameters, lhsBody as Expression), .Function(rhsName, rhsParameters, rhsBody as Expression)):
        return lhsName == rhsName && lhsParameters == rhsParameters && lhsBody == rhsBody
    
    default:
        return false
    }
}
