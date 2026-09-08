import Foundation

extension Number {
    static func convert(from value: String) throws -> Number {
        if let int = IntType(value) {
            return .int(int)
        } else if let float = FloatType(value) {
            let result = float
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        } else {
            throw EvaluationError.numericMismatch
        }
    }

    func plus(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            let (result, overflow) = lhsValue.addingReportingOverflow(rhsValue)
            guard !overflow else { throw EvaluationError.arithmeticOverflow }
            return .int(result)
        case let (.int(lhsValue), .float(rhsValue)):
            let result = FloatType(lhsValue) + rhsValue
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        case let (.float(lhsValue), .int(rhsValue)):
            let result = lhsValue + FloatType(rhsValue)
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        case let (.float(lhsValue), .float(rhsValue)):
            let result = lhsValue + rhsValue
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        }
    }

    func minus(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            let (result, overflow) = lhsValue.subtractingReportingOverflow(rhsValue)
            guard !overflow else { throw EvaluationError.arithmeticOverflow }
            return .int(result)
        case let (.int(lhsValue), .float(rhsValue)):
            let result = FloatType(lhsValue) - rhsValue
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        case let (.float(lhsValue), .int(rhsValue)):
            let result = lhsValue - FloatType(rhsValue)
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        case let (.float(lhsValue), .float(rhsValue)):
            let result = lhsValue - rhsValue
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        }
    }

    func times(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            let (result, overflow) = lhsValue.multipliedReportingOverflow(by: rhsValue)
            guard !overflow else { throw EvaluationError.arithmeticOverflow }
            return .int(result)
        case let (.int(lhsValue), .float(rhsValue)):
            let result = FloatType(lhsValue) * rhsValue
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        case let (.float(lhsValue), .int(rhsValue)):
            let result = lhsValue * FloatType(rhsValue)
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        case let (.float(lhsValue), .float(rhsValue)):
            let result = lhsValue * rhsValue
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        }
    }

    func power(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            if rhsValue >= 0 {
                let value = pow(FloatType(lhsValue), FloatType(rhsValue))
                guard value.isFinite else { throw EvaluationError.arithmeticOverflow }
                if let intValue = IntType(exactly: value) {
                    return .int(intValue)
                }
                return .float(value)
            } else {
                let result = pow(FloatType(lhsValue), FloatType(rhsValue))
                guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
                return .float(result)
            }
        case let (.int(lhsValue), .float(rhsValue)):
            let result = pow(FloatType(lhsValue), rhsValue)
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        case let (.float(lhsValue), .int(rhsValue)):
            let result = pow(lhsValue, FloatType(rhsValue))
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        case let (.float(lhsValue), .float(rhsValue)):
            let result = pow(lhsValue, rhsValue)
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        }
    }

    func floatDividedBy(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
            let result = FloatType(lhsValue) / FloatType(rhsValue)
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        case let (.int(lhsValue), .float(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
            let result = FloatType(lhsValue) / rhsValue
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        case let (.float(lhsValue), .int(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
            let result = lhsValue / FloatType(rhsValue)
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        case let (.float(lhsValue), .float(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
            let result = lhsValue / rhsValue
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
        }
    }

    func integerDividedBy(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
            let (result, overflow) = lhsValue.dividedReportingOverflow(by: rhsValue)
            guard !overflow else { throw EvaluationError.arithmeticOverflow }
            return .int(result)
        default:
            throw EvaluationError.numericMismatch
        }
    }

    func modulo(_ other: Number) throws -> Number {
        switch (self, other) {
        case let (.int(lhsValue), .int(rhsValue)):
            guard rhsValue != 0 else { throw EvaluationError.divisionByZero }
            let (result, overflow) = lhsValue.remainderReportingOverflow(dividingBy: rhsValue)
            guard !overflow else { throw EvaluationError.arithmeticOverflow }
            return .int(result)
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

    func negate() throws -> Number {
        switch self {
        case .int(let value):
            let (result, overflow) = IntType.zero.subtractingReportingOverflow(value)
            guard !overflow else { throw EvaluationError.arithmeticOverflow }
            return .int(result)
        case .float(let value):
            let result = -value
            guard result.isFinite else { throw EvaluationError.arithmeticOverflow }
            return .float(result)
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
