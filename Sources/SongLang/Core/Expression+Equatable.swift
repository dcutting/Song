extension Expression: Equatable {
    public static func ==(lhs: Expression, rhs: Expression) -> Bool {
        switch (lhs, rhs) {
        case let (.bool(lhsValue), .bool(rhsValue)):
            lhsValue == rhsValue
        case let (.number(lhsValue), .number(rhsValue)):
            lhsValue == rhsValue
        case let (.char(lhsValue), .char(rhsValue)):
            lhsValue == rhsValue
        case let (.list(lhsExprs), .list(rhsExprs)):
            lhsExprs == rhsExprs
        case let (.cons(lhsHead, lhsTail), .cons(rhsHead, rhsTail)):
            lhsHead == rhsHead && lhsTail == rhsTail
        case (.unnamed, .unnamed):
            true
        case let (.name(lhsVariable), .name(rhsVariable)):
            lhsVariable == rhsVariable
        case let (.function(lhsSubfunction), .function(rhsSubfunction)):
            lhsSubfunction == rhsSubfunction
        case let (.assign(lhsName, lhsValue), .assign(rhsName, rhsValue)):
            lhsName == rhsName && lhsValue == rhsValue
        case let (.closure(lhsName, lhsFunctions, lhsContext), .closure(rhsName, rhsFunctions, rhsContext)):
            lhsName == rhsName && lhsFunctions == rhsFunctions && lhsContext == rhsContext
        case let (.scope(lhsExpressions), .scope(rhsExpressions)):
            lhsExpressions == rhsExpressions
        case let (.call(lhsName, lhsArguments), .call(rhsName, rhsArguments)):
            lhsName == rhsName && lhsArguments == rhsArguments
        case let (.eval(lhsClosure, lhsArguments), .eval(rhsClosure, rhsArguments)):
            lhsClosure == rhsClosure && lhsArguments == rhsArguments
        case let (.tailEval(lhsClosure, lhsArguments), .tailEval(rhsClosure, rhsArguments)):
            lhsClosure == rhsClosure && lhsArguments == rhsArguments
        default:
            false
        }
    }
}
