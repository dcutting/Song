public indirect enum Expression {

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
