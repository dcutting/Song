public extension Expression {

    public func out() -> String {
        switch self {
        case let .char(char):
            return "\(char)"
        case let .list(exprs):
            do {
                return try convertToString(characters: exprs)
            } catch {
                return "\(self)"
            }
        case let .closure(_, value, _):
            return "\(value)"
        default:
            return "\(self)"
        }
    }
}
