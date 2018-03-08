extension Expression: Equatable {

    public static func ==(lhs: Expression, rhs: Expression) -> Bool {
        switch (lhs, rhs) {

        case let (.bool(lhsValue), .bool(rhsValue)):
            return lhsValue == rhsValue

        case let (.number(lhsValue), .number(rhsValue)):
            return lhsValue == rhsValue

        case let (.char(lhsValue), .char(rhsValue)):
            return lhsValue == rhsValue

        case let (.list(lhsExprs), .list(rhsExprs)):
            return lhsExprs == rhsExprs

        case let (.cons(lhsHead, lhsTail), .cons(rhsHead, rhsTail)):
            return lhsHead == rhsHead && lhsTail == rhsTail

        case (.ignore, .ignore):
            return true

        case let (.name(lhsVariable), .name(rhsVariable)):
            return lhsVariable == rhsVariable

        case let (.subfunction(lhsSubfunction), .subfunction(rhsSubfunction)):
            return lhsSubfunction == rhsSubfunction

        case let (.assign(lhsName, lhsValue), .assign(rhsName, rhsValue)):
            return lhsName == rhsName && lhsValue == rhsValue

        case let (.closure(lhsName, lhsFunctions, lhsContext), .closure(rhsName, rhsFunctions, rhsContext)):
            return lhsName == rhsName && lhsFunctions == rhsFunctions && isEqual(lhsContext: lhsContext, rhsContext: rhsContext)

        case let (.scope(lhsExpressions), .scope(rhsExpressions)):
            return lhsExpressions == rhsExpressions

        case let (.call(lhsName, lhsArguments), .call(rhsName, rhsArguments)):
            return lhsName == rhsName && lhsArguments == rhsArguments

        case let (.eval(lhsClosure, lhsArguments), .eval(rhsClosure, rhsArguments)):
            return lhsClosure == rhsClosure && lhsArguments == rhsArguments

        default:
            return false
        }
    }
}
