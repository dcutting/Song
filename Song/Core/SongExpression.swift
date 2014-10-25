import Foundation

public protocol SongExpressionLike {}

public enum SongExpression: SongExpressionLike, Equatable, Printable {

    
    case SongError(String)
    
    case SongUnit

    case SongBoolean(Bool)
    
    case SongIsUnit(SongExpressionLike)
    
    case SongInteger(Int)
    
    case SongString(String)
    
    case SongPair(SongExpressionLike, SongExpressionLike)
    
    case SongSecond(SongExpressionLike)
    
    case SongClosure(function: SongExpressionLike, context: SongContext)
    
    case SongLet(name: String, binding: SongExpressionLike, body: SongExpressionLike)
    
    case SongVariable(String)
    
    case SongFunction(name: String, parameters: [String], body: SongExpressionLike)
    
    case SongCall(closure: SongExpressionLike, arguments: [SongExpressionLike])
    
    case SongIf(condition: SongExpressionLike, then: SongExpressionLike, otherwise: SongExpressionLike)
    
    
    public var description: String {
        switch self {
            
        case let .SongError(value):
            return "<\(value)>"

        case .SongUnit:
            return "#"

        case let .SongBoolean(value):
            return value ? "yes" : "no"
            
        case let .SongIsUnit(value):
            return "isUnit(\(value))"
            
        case let .SongInteger(value):
            return "\(value)"
        
        case let .SongString(value):
            return "'\(value)'"
        
        case let .SongPair(first as SongExpression, second as SongExpression):
            return "(\(first), \(second))"
            
        case let .SongSecond(value):
            return "second(\(value))"
        
        case let .SongClosure(function as SongExpression, context):
            let contextList = contextDescription(context)
            return "[(\(contextList)) \(function)]"

        case let .SongLet(name, binding as SongExpression, body as SongExpression):
            return "let (\(name) = \(binding)) { \(body) }"
        
        case let .SongVariable(variable):
            return "\(variable)"
            
        case let .SongFunction(name, parameters, body as SongExpression):
            let parametersList = ", ".join(parameters)
            return "def \(name)(\(parametersList)) { \(body) }"
            
        case let .SongCall(closure as SongExpression, arguments):
            return descriptionSongCall(closure, arguments: arguments)
            
        case let .SongIf(condition as SongExpression, then as SongExpression, otherwise as SongExpression):
            return "if \(condition) then \(then) else \(otherwise) end"
        
        default:
            return "<unknown>"
        }
    }
    
    func descriptionSongCall(closure: SongExpression, arguments: [SongExpressionLike]) -> String {
        var argumentStrings = Array<String>()
        for arg in arguments {
            argumentStrings.append("\(arg as SongExpression)")
        }
        let argumentsList = ", ".join(argumentStrings)
        return "\(closure)(\(argumentsList))"
    }
    
    public func evaluate() -> SongExpression {
        return evaluate(SongContext())
    }
    
    public func evaluate(context: SongContext) -> SongExpression {
        switch self {

        case let .SongIsUnit(value as SongExpression):
            return evaluateSongIsUnit(value, context: context)
            
        case let .SongLet(name, binding as SongExpression, body as SongExpression):
            return evaluateSongLet(name, binding, body, context)
            
        case let .SongVariable(variable):
            return evaluateSongVariable(variable, context)

        case let .SongFunction:
            return SongClosure(function: self, context: context)
            
        case let .SongCall(closure as SongExpression, arguments):
            return evaluateSongCallClosure(closure, arguments: arguments, callingContext: context)

        case let .SongIf(condition as SongExpression, then as SongExpression, otherwise as SongExpression):
            return evaluateSongIf(condition, then: then, otherwise: otherwise, context: context)
            
        case let .SongSecond(pair as SongExpression):
            return evaluateSecond(pair, context: context)
            
        default:
            return self
        }
    }

    func evaluateSongIsUnit(value: SongExpression, context: SongContext) -> SongExpression {
        switch value.evaluate(context) {
        case .SongUnit:
            return SongBoolean(true)
        default:
            return SongBoolean(false)
        }
    }
    
    func evaluateSongLet(name: String, _ binding: SongExpression, _ body: SongExpression, _ context: SongContext) -> SongExpression {
        let letContext = extendContext(context, name: name, value: binding.evaluate(context))
        return body.evaluate(letContext)
    }
    
    func evaluateSongVariable(variable: String, _ context: SongContext) -> SongExpression {
        if let value = context[variable] {
            return value
        }
        return SongError("cannot evaluate \(variable)")
    }
    
    func evaluateSongCallClosure(closure: SongExpression, arguments: [SongExpressionLike], callingContext: SongContext) -> SongExpression {
        switch closure.evaluate(callingContext) {
        case let .SongClosure(function as SongExpression, closureContext):
            return evaluateSongCallFunction(function, closureContext: closureContext, arguments: arguments, callingContext: callingContext)
        default:
            return SongError("can only call closure")
        }
    }
    
    func evaluateSongCallFunction(function: SongExpression, closureContext: SongContext, arguments: [SongExpressionLike], callingContext: SongContext) -> SongExpression {
        switch function {
        case let .SongFunction(_, parameters, body as SongExpression):
            if arguments.count < parameters.count {
                return SongExpression.SongError("not enough arguments")
            }
            if arguments.count > parameters.count {
                return SongExpression.SongError("too many arguments")
            }
            let extendedContext = extendContext(closureContext, parameters: parameters, arguments: arguments, callingContext: callingContext)
            return body.evaluate(extendedContext)
        default:
            return SongError("closure does not wrap function")
        }
    }
    
    func evaluateSongIf(condition: SongExpression, then: SongExpression, otherwise: SongExpression, context: SongContext) -> SongExpression {
        switch condition.evaluate(context) {
        case .SongBoolean(true):
            return then.evaluate(context)
        case .SongBoolean(false):
            return otherwise.evaluate(context)
        default:
            return SongError("boolean expression expected")
        }
    }
    
    func evaluateSecond(pair: SongExpression, context: SongContext) -> SongExpression {
        return SongError("requires pair")
    }
}

public func ==(lhs: SongExpression, rhs: SongExpression) -> Bool {
    switch (lhs, rhs) {
        
    case let (.SongError(lhsError), .SongError(rhsError)):
        return lhsError == rhsError

    case (.SongUnit, .SongUnit):
        return true
        
    case let (.SongBoolean(lhsValue), .SongBoolean(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.SongInteger(lhsValue), .SongInteger(rhsValue)):
        return lhsValue == rhsValue
    
    case let (.SongString(lhsValue), .SongString(rhsValue)):
        return lhsValue == rhsValue
    
    case let (.SongPair(lhsFirst as SongExpression, lhsSecond as SongExpression),
        .SongPair(rhsFirst as SongExpression, rhsSecond as SongExpression)):
        return lhsFirst == rhsFirst && lhsSecond == rhsSecond
    
    case let (.SongClosure(lhsFunction as SongExpression, lhsContext), .SongClosure(rhsFunction as SongExpression, rhsContext)):
        return lhsFunction == rhsFunction && lhsContext == rhsContext
        
    case let (.SongVariable(lhsVariable), .SongVariable(rhsVariable)):
        return lhsVariable == rhsVariable
    
    case let (.SongFunction(lhsName, lhsParameters, lhsBody as SongExpression), .SongFunction(rhsName, rhsParameters, rhsBody as SongExpression)):
        return lhsName == rhsName && lhsParameters == rhsParameters && lhsBody == rhsBody
    
    default:
        return false
    }
}
