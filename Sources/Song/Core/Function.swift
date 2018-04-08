public struct Function {

    public let name: String?
    public let patterns: [Expression]
    public let when: Expression
    public let body: Expression
    public let type: Type

    public init(name: String?, patterns: [Expression], when: Expression, body: Expression, type: Type) {
        self.name = name
        self.patterns = patterns
        self.when = when
        self.body = body
        self.type = type
    }
}

extension Function: CustomStringConvertible {

    public var description: String {
        let params = patterns.map(String.init).joined(separator: ", ")
        let funcName = name ?? "λ"
        var whenClause = ""
        if when != .yes {
            whenClause = " When \(when)"
        }
        return "\(funcName)(\(params))\(whenClause) = \(body)"
    }
}

extension Function: Equatable {

    public static func ==(lhs: Function, rhs: Function) -> Bool {
        return lhs.name == rhs.name && lhs.patterns == rhs.patterns && lhs.when == rhs.when && lhs.body == rhs.body
    }
}
