public struct Subfunction: Equatable {

    public let name: String?
    public let patterns: [Expression]
    public let when: Expression
    public let body: Expression

    public init(name: String?, patterns: [Expression], when: Expression, body: Expression) {
        self.name = name
        self.patterns = patterns
        self.when = when
        self.body = body
    }

    public static func ==(lhs: Subfunction, rhs: Subfunction) -> Bool {
        return lhs.name == rhs.name && lhs.patterns == rhs.patterns && lhs.when == rhs.when && lhs.body == rhs.body
    }
}

public indirect enum Expression {

    case error(String)
    
    case unitValue

    case booleanValue(Bool)
    
    case integerValue(Int)

    case floatValue(Double)

    case stringValue(String)
    
    case isUnit(Expression)

    case call(name: String, arguments: [Expression])
    
    case pair(Expression, Expression)
    
    case first(Expression)
    
    case second(Expression)
    
    case closure(function: Expression, context: Context)
    
    case `let`(name: String, binding: Expression, body: Expression)
    
    case variable(String)
    
    case subfunction(Subfunction)
    
    case callAnonymous(closure: Expression, arguments: [Expression])
    
    case conditional(condition: Expression, then: Expression, otherwise: Expression)

    case parameter(String)
}
