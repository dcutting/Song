extension Expression: Equatable {
}

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
        
    case let (.Error(lhsError), .Error(rhsError)):
        return lhsError == rhsError
        
    case (.UnitValue, .UnitValue):
        return true
        
    case let (.BooleanValue(lhsValue), .BooleanValue(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.IntegerValue(lhsValue), .IntegerValue(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.StringValue(lhsValue), .StringValue(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.Pair(lhsFirst, lhsSecond),
        .Pair(rhsFirst, rhsSecond)):
        return lhsFirst == rhsFirst && lhsSecond == rhsSecond
        
    case let (.Closure(lhsFunction, lhsContext), .Closure(rhsFunction, rhsContext)):
        return lhsFunction == rhsFunction && lhsContext == rhsContext
        
    case let (.Variable(lhsVariable), .Variable(rhsVariable)):
        return lhsVariable == rhsVariable
        
    case let (.Function(lhsName, lhsParameters, lhsBody), .Function(rhsName, rhsParameters, rhsBody)):
        return lhsName == rhsName && lhsParameters == rhsParameters && lhsBody == rhsBody
        
    default:
        return false
    }
}
