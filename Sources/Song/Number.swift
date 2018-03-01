public typealias IntType = Int64
public typealias FloatType = Float64

public enum Number {
    case int(IntType)
    case float(FloatType)
}

extension Number {

    static func convert(from value: String) throws -> Number {
        if let int = IntType(value) {
            return Number.int(int)
        } else if let float = FloatType(value) {
            return Number.float(float)
        } else {
            throw EvaluationError.numericMismatch
        }
    }
}

extension Number {

    func plus(_ other: Number) -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            return .int(lhsValue + rhsValue)
        case let (.int(lhsValue), .float(rhsValue)):
            return .float(FloatType(lhsValue) + rhsValue)
        case let (.float(lhsValue), .int(rhsValue)):
            return .float(lhsValue + FloatType(rhsValue))
        case let (.float(lhsValue), .float(rhsValue)):
            return .float(lhsValue + rhsValue)
        }
    }

    func minus(_ other: Number) -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            return .int(lhsValue - rhsValue)
        case let (.int(lhsValue), .float(rhsValue)):
            return .float(FloatType(lhsValue) - rhsValue)
        case let (.float(lhsValue), .int(rhsValue)):
            return .float(lhsValue - FloatType(rhsValue))
        case let (.float(lhsValue), .float(rhsValue)):
            return .float(lhsValue - rhsValue)
        }
    }

    func times(_ other: Number) -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            return .int(lhsValue * rhsValue)
        case let (.int(lhsValue), .float(rhsValue)):
            return .float(FloatType(lhsValue) * rhsValue)
        case let (.float(lhsValue), .int(rhsValue)):
            return .float(lhsValue * FloatType(rhsValue))
        case let (.float(lhsValue), .float(rhsValue)):
            return .float(lhsValue * rhsValue)
        }
    }

    func floatDividedBy(_ other: Number) -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            return .float(FloatType(lhsValue) / FloatType(rhsValue))
        case let (.int(lhsValue), .float(rhsValue)):
            return .float(FloatType(lhsValue) / rhsValue)
        case let (.float(lhsValue), .int(rhsValue)):
            return .float(lhsValue / FloatType(rhsValue))
        case let (.float(lhsValue), .float(rhsValue)):
            return .float(lhsValue / rhsValue)
        }
    }

    func integerDividedBy(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            return .int(lhsValue / rhsValue)
        default:
            throw EvaluationError.numericMismatch
        }
    }

    func modulo(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            return .int(lhsValue % rhsValue)
        default:
            throw EvaluationError.numericMismatch
        }
    }

    func lessThan(_ other: Number) -> Bool {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            return lhsValue < rhsValue
        case let (.int(lhsValue), .float(rhsValue)):
            return FloatType(lhsValue) < rhsValue
        case let (.float(lhsValue), .int(rhsValue)):
            return lhsValue < FloatType(rhsValue)
        case let (.float(lhsValue), .float(rhsValue)):
            return lhsValue < rhsValue
        }
    }

    func lessThanOrEqualTo(_ other: Number) -> Bool {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            return lhsValue <= rhsValue
        case let (.int(lhsValue), .float(rhsValue)):
            return FloatType(lhsValue) <= rhsValue
        case let (.float(lhsValue), .int(rhsValue)):
            return lhsValue <= FloatType(rhsValue)
        case let (.float(lhsValue), .float(rhsValue)):
            return lhsValue <= rhsValue
        }
    }

    func greaterThan(_ other: Number) -> Bool {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            return lhsValue > rhsValue
        case let (.int(lhsValue), .float(rhsValue)):
            return FloatType(lhsValue) > rhsValue
        case let (.float(lhsValue), .int(rhsValue)):
            return lhsValue > FloatType(rhsValue)
        case let (.float(lhsValue), .float(rhsValue)):
            return lhsValue > rhsValue
        }
    }

    func greaterThanOrEqualTo(_ other: Number) -> Bool {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            return lhsValue >= rhsValue
        case let (.int(lhsValue), .float(rhsValue)):
            return FloatType(lhsValue) >= rhsValue
        case let (.float(lhsValue), .int(rhsValue)):
            return lhsValue >= FloatType(rhsValue)
        case let (.float(lhsValue), .float(rhsValue)):
            return lhsValue >= rhsValue
        }
    }

    func equalTo(_ other: Number) throws -> Bool {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            return lhsValue == rhsValue
        default:
            throw EvaluationError.numericMismatch
        }
    }
}

extension Number: Equatable, CustomStringConvertible {

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

    public var description: String {
        switch self {
        case let .int(n):
            return "\(n)"
        case let .float(n):
            return "\(n)"
        }
    }
}
