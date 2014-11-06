import Foundation

public protocol ExpressionLike {}

public enum Expression: ExpressionLike, Equatable, Printable {

    
    case Error(String)
    
    case Unit

    case Boolean(Bool)
    
    case IsUnit(ExpressionLike)
    
    case Integer(Int)
    
    case Plus(ExpressionLike, ExpressionLike)
    
    case SongString(String)
    
    case Pair(ExpressionLike, ExpressionLike)
    
    case Second(ExpressionLike)
    
    case Closure(function: ExpressionLike, context: SongContext)
    
    case Let(name: String, binding: ExpressionLike, body: ExpressionLike)
    
    case Variable(String)
    
    case Function(name: String, parameters: [String], body: ExpressionLike)
    
    case Call(closure: ExpressionLike, arguments: [ExpressionLike])
    
    case Conditional(condition: ExpressionLike, then: ExpressionLike, otherwise: ExpressionLike)
    
    
    public var description: String {
        switch self {
            
        case let .Error(value):
            return "<\(value)>"

        case .Unit:
            return "#"

        case let .Boolean(value):
            return value ? "yes" : "no"
            
        case let .IsUnit(value):
            return "isUnit(\(value))"
            
        case let .Integer(value):
            return "\(value)"
        
        case let .Plus(left, right):
            return "\(left) + \(right)"
            
        case let .SongString(value):
            return "'\(value)'"
        
        case let .Pair(first as Expression, second as Expression):
            return "(\(first), \(second))"
            
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
            let parametersList = ", ".join(parameters)
            return "def \(name)(\(parametersList)) { \(body) }"
            
        case let .Call(closure as Expression, arguments):
            return descriptionCall(closure, arguments: arguments)
            
        case let .Conditional(condition as Expression, then as Expression, otherwise as Expression):
            return "if \(condition) then \(then) else \(otherwise) end"
        
        default:
            return "<unknown>"
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
        return evaluate(SongContext())
    }
    
    public func evaluate(context: SongContext) -> Expression {
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
            
        case let .Second(pair as Expression):
            return evaluateSecond(pair, context: context)
            
        default:
            return self
        }
    }

    func evaluateIsUnit(value: Expression, context: SongContext) -> Expression {
        switch value.evaluate(context) {
        case .Unit:
            return Boolean(true)
        default:
            return Boolean(false)
        }
    }
    
    func evaluatePlus(left: Expression, _ right: Expression, context: SongContext) -> Expression {
        let evaluatedLeft = left.evaluate(context)
        let evaluatedRight = right.evaluate(context)
        switch (evaluatedLeft, evaluatedRight) {
        case let (.Integer(leftValue), .Integer(rightValue)):
            return Expression.Integer(leftValue + rightValue)
        default:
            return Error("cannot add \(evaluatedLeft) to \(evaluatedRight)")
        }
    }
    
    func evaluateLet(name: String, _ binding: Expression, _ body: Expression, _ context: SongContext) -> Expression {
        let letContext = extendContext(context, name: name, value: binding.evaluate(context))
        return body.evaluate(letContext)
    }
    
    func evaluateVariable(variable: String, _ context: SongContext) -> Expression {
        if let value = context[variable] {
            return value
        }
        return Error("cannot evaluate \(variable)")
    }
    
    func evaluateCallClosure(closure: Expression, arguments: [ExpressionLike], callingContext: SongContext) -> Expression {
        let evaluatedClosure = closure.evaluate(callingContext)
        switch evaluatedClosure {
        case let .Closure(function as Expression, closureContext):
            return evaluateCallFunction(function, closureContext: closureContext, arguments: arguments, callingContext: callingContext, closure: evaluatedClosure)
        default:
            return Error("\(closure) is not a closure")
        }
    }
    
    func evaluateCallFunction(function: Expression, closureContext: SongContext, arguments: [ExpressionLike], callingContext: SongContext, closure: Expression) -> Expression {
        switch function {
        case let .Function(name, parameters, body as Expression):
            if arguments.count < parameters.count {
                return Expression.Error("not enough arguments")
            }
            if arguments.count > parameters.count {
                return Expression.Error("too many arguments")
            }
            let extendedContext = extendContext(closureContext, parameters: parameters, arguments: arguments, callingContext: callingContext)
            let recursiveContext = extendContext(extendedContext, name: name, value: closure)
            return body.evaluate(recursiveContext)
        default:
            return Error("closure does not wrap function")
        }
    }
    
    func evaluateConditional(condition: Expression, then: Expression, otherwise: Expression, context: SongContext) -> Expression {
        switch condition.evaluate(context) {
        case .Boolean(true):
            return then.evaluate(context)
        case .Boolean(false):
            return otherwise.evaluate(context)
        default:
            return Error("boolean expression expected")
        }
    }
    
    func evaluateSecond(pair: Expression, context: SongContext) -> Expression {
        let evaluatedPair = pair.evaluate(context)
        switch evaluatedPair {
        case let Pair(fst as Expression, snd as Expression):
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

    case (.Unit, .Unit):
        return true
        
    case let (.Boolean(lhsValue), .Boolean(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.Integer(lhsValue), .Integer(rhsValue)):
        return lhsValue == rhsValue
    
    case let (.SongString(lhsValue), .SongString(rhsValue)):
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
