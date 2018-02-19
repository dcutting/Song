extension Expression: Equatable {
}

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
        
    case let (.booleanValue(lhsValue), .booleanValue(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.integerValue(lhsValue), .integerValue(rhsValue)):
        return lhsValue == rhsValue

    case let (.floatValue(lhsValue), .floatValue(rhsValue)):
        return lhsValue == rhsValue

    case let (.stringValue(lhsValue), .stringValue(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.list(lhsExprs), .list(rhsExprs)):
        return lhsExprs == rhsExprs

    case let (.listConstructor(lhsHead, lhsTail), .listConstructor(rhsHead, rhsTail)):
        return lhsHead == rhsHead && lhsTail == rhsTail
        
    case let (.variable(lhsVariable), .variable(rhsVariable)):
        return lhsVariable == rhsVariable

    case let (.subfunction(lhsSubfunction), .subfunction(rhsSubfunction)):
        return lhsSubfunction == rhsSubfunction

    case let (.constant(lhsName, lhsValue), .constant(rhsName, rhsValue)):
        return lhsName == rhsName && lhsValue == rhsValue

    case let (.closure(lhsFunction, lhsContext), .closure(rhsFunction, rhsContext)):
        return lhsFunction == rhsFunction && isEqual(lhsContext: lhsContext, rhsContext: rhsContext)

    case let (.call(lhsName, lhsArguments), .call(rhsName, rhsArguments)):
        return lhsName == rhsName && lhsArguments == rhsArguments

    case let (.callAnonymous(lhsClosure, lhsArguments), .callAnonymous(rhsClosure, rhsArguments)):
        return lhsClosure == rhsClosure && lhsArguments == rhsArguments

    default:
        return false
    }
}
