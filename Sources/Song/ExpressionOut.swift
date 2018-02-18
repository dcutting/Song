public extension Expression {

    public func out() -> String {
        switch self {
        case let .stringValue(value):
            return value
        default:
            return "\(self)"
        }
    }
}
