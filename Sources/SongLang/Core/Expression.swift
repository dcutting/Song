public typealias BuiltIn = ([Expression], Context) throws -> Expression

public indirect enum Expression {

    case bool(Bool)
    case number(Number)
    case char(Character)
    case list([Expression])
    case cons([Expression], Expression)

    case ignore
    case name(String)

    case function(Function)
    case assign(variable: Expression, value: Expression)

    case closure(String?, [Expression], Context)
    case scope([Expression])

    case call(String, [Expression])
    case eval(Expression, [Expression])

    case tailEval(Expression, [Expression])

    case builtIn(BuiltIn)
}

public extension Expression {

    static var yes: Expression {
        return .bool(true)
    }

    static var no: Expression {
        return .bool(false)
    }

    static func int(_ int: IntType) -> Expression {
        return .number(.int(int))
    }

    static func float(_ float: FloatType) -> Expression {
        return .number(.float(float))
    }

    static func string(_ string: String) -> Expression {
        return .list(Array(string).map(Expression.char))
    }

    static func lambda(_ patterns: [Expression], _ body: Expression) -> Expression {
        return .function(Function(name: nil, patterns: patterns, when: .yes, body: body))
    }
}
