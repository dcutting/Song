public typealias SongContext = [String: SongExpression]

public protocol SongExpressionLike {}

public enum SongExpression: SongExpressionLike, Equatable, Printable {

    case SongError(String)
    
    case SongUnit
    case SongInteger(Int)
    case SongString(String)
    case SongPair(SongExpressionLike, SongExpressionLike)
    
    case SongLet(name: String, binding: SongExpressionLike, body: SongExpressionLike)
    case SongVariable(String)
    
    case SongFunction(name: String, parameters: [String], body: SongExpressionLike)
    case SongClosure(function: SongExpressionLike, context: SongContext)
    
    public var description: String {
        switch self {

        case .SongUnit:
            return "#"
        case let .SongInteger(value):
            return "\(value)"
        case let .SongString(value):
            return "'\(value)'"
        case let .SongPair(first as SongExpression, second as SongExpression):
            return "(\(first), \(second))"
        
        case let .SongLet(name, binding as SongExpression, body as SongExpression):
            return "let (\(name) = \(binding)) { \(body) }"
        case let .SongVariable(variable):
            return "\(variable)"
            
        case let .SongFunction(name, params, body as SongExpression):
            let paramsList = ", ".join(params)
            return "def \(name)(\(paramsList)) { \(body) }"
        
        default:
            return "<unknown>"
        }
    }
    
    public func evaluate() -> SongExpression {
        return evaluate(SongContext())
    }
    
    public func evaluate(context: SongContext) -> SongExpression {
        switch self {

        case let .SongLet(name, binding as SongExpression, body as SongExpression):
            var letContext = context
            letContext[name] = binding.evaluate(context)
            return body.evaluate(letContext)
            
        case let .SongVariable(variable):
            if let value = context[variable] {
                return value
            }
            return SongExpression.SongError("cannot evaluate \(variable)")

        case let .SongFunction(name, parameters, body as SongExpression):
            return SongClosure(function: self, context: context)
            
        default:
            return self
        }
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
        
    case let (.SongVariable(lhsVariable), .SongVariable(rhsVariable)):
        return lhsVariable == rhsVariable
    
    case let (.SongFunction(lhsName, lhsParameters, lhsBody as SongExpression), .SongFunction(rhsName, rhsParameters, rhsBody as SongExpression)):
        return lhsName == rhsName && lhsParameters == rhsParameters && lhsBody == rhsBody
    case let (.SongClosure(lhsFunction as SongExpression, lhsContext), .SongClosure(rhsFunction as SongExpression, rhsContext)):
        return lhsFunction == rhsFunction && lhsContext == rhsContext
    
    default:
        return false
    }
}
