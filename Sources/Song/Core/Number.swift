public typealias IntType = Int64
public typealias FloatType = Float64

public enum Number {
    case int(IntType)
    case float(FloatType)
}

extension Number: CustomStringConvertible {

    public var description: String {
        switch self {
        case let .int(n):
            return "\(n)"
        case let .float(n):
            return "\(n)"
        }
    }
}

extension Number: Equatable {

    public static func ==(lhs: Number, rhs: Number) -> Bool {
        switch (lhs, rhs) {
        case (.int, .float), (.float, .int):
            return false
        case let (.int(lhsValue), .int(rhsValue)):
            return lhsValue == rhsValue
        case let (.float(lhsValue), .float(rhsValue)):
            return lhsValue == rhsValue
        }
    }
}
