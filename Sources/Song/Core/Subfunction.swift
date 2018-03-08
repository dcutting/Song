public struct Subfunction {

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
}

extension Subfunction: CustomStringConvertible {

    public var description: String {
        let parametersList = patterns.map { "\($0)" }.joined(separator: ", ")
        if let funcName = name {
            return "\(funcName)(\(parametersList)) When \(when) = \(body)"
        }
        return "λ(\(parametersList)) = \(body)"
    }
}

extension Subfunction: Equatable {

    public static func ==(lhs: Subfunction, rhs: Subfunction) -> Bool {
        return lhs.name == rhs.name && lhs.patterns == rhs.patterns && lhs.when == rhs.when && lhs.body == rhs.body
    }
}
