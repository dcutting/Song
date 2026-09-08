import Testing
@testable import SongLang

struct ArithmeticOverflowTests {
    private static let operations: [(String, @Sendable () throws -> Number)] = [
        ("integer addition", { try Number.int(.max).plus(.int(1)) }),
        ("integer subtraction", { try Number.int(.min).minus(.int(1)) }),
        ("integer multiplication", { try Number.int(.max).times(.int(2)) }),
        ("integer division", { try Number.int(.min).integerDividedBy(.int(-1)) }),
        ("integer remainder", { try Number.int(.min).modulo(.int(-1)) }),
        ("integer negation", { try Number.int(.min).negate() }),
        ("float addition", {
            try Number.float(.greatestFiniteMagnitude).plus(.float(.greatestFiniteMagnitude))
        }),
        ("float subtraction", {
            try Number.float(-.greatestFiniteMagnitude).minus(.float(.greatestFiniteMagnitude))
        }),
        ("float division", {
            try Number.float(.greatestFiniteMagnitude).floatDividedBy(.float(0.5))
        }),
        ("power overflow", { try Number.int(10).power(.int(1000)) }),
        ("power NaN", { try Number.float(-1).power(.float(0.5)) })
    ]

    @Test(arguments: operations)
    func test_arithmeticOverflow(name: String, operation: @Sendable () throws -> Number) {
        do {
            _ = try operation()
            Issue.record("Expected arithmetic overflow for \(name)")
        } catch {
            guard case EvaluationError.arithmeticOverflow = error else {
                Issue.record("Expected arithmetic overflow for \(name), got \(error)")
                return
            }
        }
    }
}
