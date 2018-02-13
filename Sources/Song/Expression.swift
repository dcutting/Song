public indirect enum Expression {

    case error(String)
    
    case unitValue

    case booleanValue(Bool)
    
    case integerValue(Int)

    case floatValue(Double)

    case stringValue(String)
    
    case isUnit(Expression)

    case builtin(name: String, arguments: [Expression])
    
    case plus(Expression, Expression)
    
    case pair(Expression, Expression)
    
    case first(Expression)
    
    case second(Expression)
    
    case closure(function: Expression, context: Context)
    
    case `let`(name: String, binding: Expression, body: Expression)
    
    case variable(String)
    
    case function(name: String?, parameters: [String], body: Expression)
    
    case call(closure: Expression, arguments: [Expression])
    
    case conditional(condition: Expression, then: Expression, otherwise: Expression)
}
