import Foundation

extension Number {

    static func convert(from value: String) throws -> Number {
        let result: Number
        if let int = IntType(value) {
            result = .int(int)
        } else if let float = FloatType(value) {
            result = .float(float)
        } else {
            throw EvaluationError.numericMismatch
        }
        return result
    }

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

    func power(_ other: Number) -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            if rhsValue >= 0 {
                let value = pow(FloatType(lhsValue), FloatType(rhsValue))
                if let intValue = Int(exactly: value) {
                    return .int(intValue)
                }
                return .float(value)
            } else {
                return .float(pow(FloatType(lhsValue), FloatType(rhsValue)))
            }
        case let (.int(lhsValue), .float(rhsValue)):
            return .float(pow(FloatType(lhsValue), rhsValue))
        case let (.float(lhsValue), .int(rhsValue)):
            return .float(pow(lhsValue, FloatType(rhsValue)))
        case let (.float(lhsValue), .float(rhsValue)):
            return .float(pow(lhsValue, rhsValue))
        }
    }

    func floatDividedBy(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
            return .float(FloatType(lhsValue) / FloatType(rhsValue))
        case let (.int(lhsValue), .float(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
            return .float(FloatType(lhsValue) / rhsValue)
        case let (.float(lhsValue), .int(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
            return .float(lhsValue / FloatType(rhsValue))
        case let (.float(lhsValue), .float(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
            return .float(lhsValue / rhsValue)
        }
    }

    func integerDividedBy(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
            return .int(lhsValue / rhsValue)
        default:
            throw EvaluationError.numericMismatch
        }
    }

    func modulo(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
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

    func negate() -> Number {
        switch self {
        case .int(let value):
            return .int(-value)
        case .float(let value):
            return .float(-value)
        }
    }

    func truncate() -> Number {
        switch self {
        case .int:
            return self
        case .float(let value):
            return .int(IntType(value))
        }
    }
}
