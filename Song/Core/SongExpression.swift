public typealias SongContext = [String: SongExpression]

public protocol SongExpressionLike {}

public enum SongExpression: SongExpressionLike, Equatable, Printable {

    case SongError(String)
    
    case SongUnit
    case SongInteger(Int)
    case SongString(String)
    case SongPair(SongExpressionLike, SongExpressionLike)
    
    case SongVariable(String)
    
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
        
        case let .SongVariable(variable):
            return "\(variable)"
        
        default:
            return "<unknown>"
        }
    }
    
    public func evaluate() -> SongExpression {
        return evaluate(SongContext())
    }
    
    public func evaluate(context: SongContext) -> SongExpression {
        switch self {

        case let .SongVariable(variable):
            if let value = context[variable] {
                return value
            }
            return SongExpression.SongError("cannot evaluate \(variable)")

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
    
    default:
        return false
    }
}
