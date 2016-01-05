public indirect enum Expression: Equatable {

    case Error(String)
    
    case UnitValue

    case BooleanValue(Bool)
    
    case IntegerValue(Int)
    
    case StringValue(String)
    
    case IsUnit(Expression)
    
    case Plus(Expression, Expression)
    
    case Pair(Expression, Expression)
    
    case First(Expression)
    
    case Second(Expression)
    
    case Closure(function: Expression, context: Context)
    
    case Let(name: String, binding: Expression, body: Expression)
    
    case Variable(String)
    
    case Function(name: String?, parameters: [String], body: Expression)
    
    case Call(closure: Expression, arguments: [Expression])
    
    case Conditional(condition: Expression, then: Expression, otherwise: Expression)
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
