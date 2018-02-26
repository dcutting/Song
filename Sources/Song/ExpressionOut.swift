public extension Expression {

    public func out() -> String {
        switch self {
        case let .stringValue(value):
            return value
        case let .list(exprs):
            do {
                let string = try convertToString(characters: exprs)
                return string
            } catch {
                return "\(self)"
            }
        case let .closure(value, _):
            return "\(value)"
        default:
            return "\(self)"
        }
    }
}
