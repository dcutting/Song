import Foundation

public protocol SongExpressionLike {}

public enum SongExpression: SongExpressionLike, Equatable, Printable {

    
    case SongError(String)
    
    case SongUnit

    case SongInteger(Int)
    
    case SongString(String)
    
    case SongPair(SongExpressionLike, SongExpressionLike)
    
    case SongClosure(function: SongExpressionLike, context: SongContext)
    
    case SongLet(name: String, binding: SongExpressionLike, body: SongExpressionLike)
    
    case SongVariable(String)
    
    case SongFunction(name: String, parameters: [String], body: SongExpressionLike)
    
    case SongCall(closure: SongExpressionLike, arguments: [SongExpressionLike])
    
    
    public var description: String {
        switch self {
            
        case let .SongError(value):
            return "<\(value)>"

        case .SongUnit:
            return "#"

        case let .SongInteger(value):
            return "\(value)"
        
        case let .SongString(value):
            return "'\(value)'"
        
        case let .SongPair(first as SongExpression, second as SongExpression):
            return "(\(first), \(second))"
        
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

        case let .SongLet(name, binding as SongExpression, body as SongExpression):
            return evaluateSongLet(name, binding, body, context)
            
        case let .SongVariable(variable):
            return evaluateSongVariable(variable, context)

        case let .SongFunction(name, parameters, body as SongExpression):
            return SongClosure(function: self, context: context)
            
        case let .SongCall(closure as SongExpression, arguments):
            return evaluateSongCall(closure)

        default:
            return self
        }
    }

    func evaluateSongLet(name: String, _ binding: SongExpression, _ body: SongExpression, _ context: SongContext) -> SongExpression {
        var letContext = context
        letContext[name] = binding.evaluate(context)
        return body.evaluate(letContext)
    }

    func evaluateSongVariable(variable: String, _ context: SongContext) -> SongExpression {
        if let value = context[variable] {
            return value
        }
        return SongError("cannot evaluate \(variable)")
    }
    
    func evaluateSongCall(closure: SongExpression) -> SongExpression {
        switch closure {
        case let .SongClosure(function as SongExpression, closureContext):
            return evaluateSongCallFunction(function)
        default:
            return .SongError("can only call closure")
        }
    }
    
    func evaluateSongCallFunction(function: SongExpression) -> SongExpression {
        return .SongError("closure does not wrap function")
    }
}

public func ==(lhs: SongExpression, rhs: SongExpression) -> Bool {
    switch (lhs, rhs) {
        
    case let (.SongError(lhsError), .SongError(rhsError)):
        return lhsError == rhsError

    case (.SongUnit, .SongUnit):
        return true
        
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
