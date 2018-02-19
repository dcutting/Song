extension Expression: Equatable {
}

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
        
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
        
    case let (.variable(lhsVariable), .variable(rhsVariable)):
        return lhsVariable == rhsVariable

    case let (.constant(lhsName, lhsValue), .constant(rhsName, rhsValue)):
        return lhsName == rhsName && lhsValue == rhsValue

    case let (.subfunction(lhsSubfunction), .subfunction(rhsSubfunction)):
        return lhsSubfunction == rhsSubfunction

    case let (.closure(lhsFunction, lhsContext), .closure(rhsFunction, rhsContext)):
        return lhsFunction == rhsFunction && lhsContext == rhsContext
    }
}
