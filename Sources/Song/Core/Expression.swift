public indirect enum Expression {

    case bool(Bool)
    case number(Number)
    case char(Character)
    case list([Expression])
    case cons([Expression], Expression)

    case ignore
    case name(String)

    case subfunction(Subfunction)
    case assign(variable: Expression, value: Expression)

    case closure(String?, [Expression], Context)
    case scope([Expression])

    case call(String, [Expression])
    case eval(Expression, [Expression])
}

public extension Expression {

    public static func int(_ int: IntType) -> Expression {
        return .number(.int(int))
    }

    public static func float(_ float: FloatType) -> Expression {
        return .number(.float(float))
    }

    public static func string(_ string: String) -> Expression {
        return .list(Array(string).map(Expression.char))
    }

    public static func lambda(_ patterns: [Expression], _ body: Expression) -> Expression {
        return .subfunction(Subfunction(name: nil, patterns: patterns, when: .bool(true), body: body))
    }
}
