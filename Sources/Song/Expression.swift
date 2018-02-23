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

    case booleanValue(Bool)
    case numberValue(Number)
    case stringValue(String)
    case list([Expression])
    case listConstructor([Expression], Expression)
    case closure(closure: Expression, context: Context)

    case variable(String)
    case anyVariable
    case call(name: String, arguments: [Expression])
    case callAnonymous(closure: Expression, arguments: [Expression])

    case subfunction(Subfunction)
    case constant(variable: Expression, value: Expression)

    case scope([Expression])
}

public extension Expression {

    public static func integerValue(_ int: IntType) -> Expression {
        return .numberValue(Number.int(int))
    }

    public static func floatValue(_ float: FloatType) -> Expression {
        return .numberValue(Number.float(float))
    }
}
