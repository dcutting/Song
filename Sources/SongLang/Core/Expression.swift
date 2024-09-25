public indirect enum Expression: Sendable, Equatable {
    case bool(Bool)
    case number(Number)
    case char(Character)
    case list([Expression])
    case cons([Expression], Expression)
    case unnamed
    case name(String)
    case function(Function)
    case assign(variable: Expression, value: Expression)
    case closure(String?, [Expression], Context)
    case scope([Expression])
    case call(String, [Expression])
    case eval(Expression, [Expression])
    case tailEval(Expression, [Expression])
    case builtIn(BuiltInName)
}

public extension SongLang.Expression {
    static var yes: Expression {
        .bool(true)
    }

    static var no: Expression {
        .bool(false)
    }

    static func int(_ int: IntType) -> Expression {
        .number(.int(int))
    }

    static func float(_ float: FloatType) -> Expression {
        .number(.float(float))
    }

    static func string(_ string: String) -> Expression {
        .list(Array(string).map(Expression.char))
    }

    static func lambda(_ patterns: [Expression], _ body: Expression) -> Expression {
        .function(Function(name: nil, patterns: patterns, when: .yes, body: body))
    }
}
