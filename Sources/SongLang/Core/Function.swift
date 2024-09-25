public struct Function: Sendable, Equatable {
    public let name: String?
    public let patterns: [Expression]
    public let when: Expression
    public let body: Expression
}

extension Function: CustomStringConvertible {
    public var description: String {
        let params = patterns.map(String.init).joined(separator: ", ")
        let funcName = name ?? "λ"
        let whenClause = when == .yes ? "" : " When \(when)"
        return "\(funcName)(\(params))\(whenClause) = \(body)"
    }
}
