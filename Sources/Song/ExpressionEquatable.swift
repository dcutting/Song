extension Expression: Equatable {
}

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
        
    case let (.error(lhsError), .error(rhsError)):
        return lhsError == rhsError
        
    case (.unitValue, .unitValue):
        return true
        
    case let (.booleanValue(lhsValue), .booleanValue(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.integerValue(lhsValue), .integerValue(rhsValue)):
        return lhsValue == rhsValue

    case let (.floatValue(lhsValue), .floatValue(rhsValue)):
        return lhsValue == rhsValue

    case let (.stringValue(lhsValue), .stringValue(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.pair(lhsFirst, lhsSecond), .pair(rhsFirst, rhsSecond)):
        return lhsFirst == rhsFirst && lhsSecond == rhsSecond
        
    case let (.closure(lhsFunction, lhsContext), .closure(rhsFunction, rhsContext)):
        return lhsFunction == rhsFunction && lhsContext == rhsContext
        
    case let (.variable(lhsVariable), .variable(rhsVariable)):
        return lhsVariable == rhsVariable
        
    case let (.function(lhsName, lhsParameters, lhsBody), .function(rhsName, rhsParameters, rhsBody)):
        return lhsName == rhsName && lhsParameters == rhsParameters && lhsBody == rhsBody

    default:
        return false
    }
}
