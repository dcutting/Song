public extension Expression {

    public func out() -> String {
        switch self {
        case let .stringValue(value):
            return value
        case let .closure(value, _):
            return "\(value)"
        default:
            return "\(self)"
        }
    }
}
