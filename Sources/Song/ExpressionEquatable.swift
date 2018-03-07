extension Expression: Equatable {
}

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
        
    case let (.bool(lhsValue), .bool(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.number(lhsValue), .number(rhsValue)):
        return lhsValue == rhsValue

    case let (.char(lhsValue), .char(rhsValue)):
        return lhsValue == rhsValue

    case let (.list(lhsExprs), .list(rhsExprs)):
        return lhsExprs == rhsExprs

    case let (.listCons(lhsHead, lhsTail), .listCons(rhsHead, rhsTail)):
        return lhsHead == rhsHead && lhsTail == rhsTail

    case (.anyVariable, .anyVariable):
        return true
        
    case let (.variable(lhsVariable), .variable(rhsVariable)):
        return lhsVariable == rhsVariable

    case let (.subfunction(lhsSubfunction), .subfunction(rhsSubfunction)):
        return lhsSubfunction == rhsSubfunction

    case let (.constant(lhsName, lhsValue), .constant(rhsName, rhsValue)):
        return lhsName == rhsName && lhsValue == rhsValue

    case let (.closure(lhsName, lhsFunctions, lhsContext), .closure(rhsName, rhsFunctions, rhsContext)):
        return lhsName == rhsName && lhsFunctions == rhsFunctions && isEqual(lhsContext: lhsContext, rhsContext: rhsContext)

    case let (.call(lhsName, lhsArguments), .call(rhsName, rhsArguments)):
        return lhsName == rhsName && lhsArguments == rhsArguments

    case let (.callAnonymous(lhsClosure, lhsArguments), .callAnonymous(rhsClosure, rhsArguments)):
        return lhsClosure == rhsClosure && lhsArguments == rhsArguments

    case let (.scope(lhsExpressions), .scope(rhsExpressions)):
        return lhsExpressions == rhsExpressions

    default:
        return false
    }
}
