public typealias IntType = Int
public typealias FloatType = Float64

public enum Number: Sendable, Equatable {
    case int(IntType)
    case float(FloatType)
}

extension Number: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .int(n):
            "\(n)"
        case let .float(n):
            "\(n)"
        }
    }
}
