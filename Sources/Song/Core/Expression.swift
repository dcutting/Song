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

    case bool(Bool)
    case number(Number)
    case char(Character)
    case list([Expression])
    case listCons([Expression], Expression)

    case ignore
    case variable(String)

    case subfunction(Subfunction)
    case assign(variable: Expression, value: Expression)

    case closure(String?, [Expression], Context)
    case scope([Expression])

    case call(String, [Expression])
    case callAnon(Expression, [Expression])
}

public extension Expression {

    public static func int(_ int: IntType) -> Expression {
        return .number(.int(int))
    }

    public static func float(_ float: FloatType) -> Expression {
        return .number(.float(float))
    }

    public static func string(_ string: String) -> Expression {
        let chars = Array(string).map { Expression.char($0) }
        return .list(chars)
    }
}
