import XCTest
import Song

class BuiltinFunctionTests: XCTestCase {

    // Invalid types.

    func test_arithmetic_nonIntegerValue_throws() {
        let op = Expression.call(name: "+", arguments: [.integerValue(5), .stringValue("hi")])
        XCTAssertThrowsError(try op.evaluate())
    }

    func test_logical_nonBooleanValue_throws() {
        let op = Expression.call(name: "and", arguments: [.booleanValue(true), .stringValue("hi")])
        XCTAssertThrowsError(try op.evaluate())
    }

    func test_logicalNot_nonBooleanValue_throws() {
        let op = Expression.call(name: "not", arguments: [.stringValue("hi")])
        XCTAssertThrowsError(try op.evaluate())
    }

    // Invalid number of arguments.

    func test_relational_notTwoArgs_throws() {
        let op = Expression.call(name: "<", arguments: [.integerValue(3)])
        XCTAssertThrowsError(try op.evaluate())
    }

    func test_logical_notTwoArgs_throws() {
        let op = Expression.call(name: "and", arguments: [.booleanValue(true)])
        XCTAssertThrowsError(try op.evaluate())
    }

    func test_logicalNot_notOneArg_throws() {
        let op = Expression.call(name: "not", arguments: [.booleanValue(true), .booleanValue(true)])
        XCTAssertThrowsError(try op.evaluate())
    }

    // Evaluates arguments.

    func test_evaluatesArithmeticArgs() {
        let left = Expression.variable("x")
        let right = Expression.variable("y")
        let op = Expression.call(name: "+", arguments: [left, right])
        assertNoThrow {
            let result = try op.evaluate(context: ["x": [.integerValue(9)], "y": [.integerValue(5)]])
            XCTAssertEqual(Expression.integerValue(14), result)
        }
    }

    func test_evaluatesRelationalArgs() {
        let left = Expression.variable("x")
        let right = Expression.variable("y")
        let op = Expression.call(name: "<", arguments: [left, right])
        assertNoThrow {
            let result = try op.evaluate(context: ["x": [.integerValue(9)], "y": [.integerValue(5)]])
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_evaluatesLogicalArgs() {
        let left = Expression.variable("x")
        let right = Expression.variable("y")
        let op = Expression.call(name: "and", arguments: [left, right])
        assertNoThrow {
            let result = try op.evaluate(context: ["x": [.booleanValue(false)], "y": [.booleanValue(true)]])
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_evaluatesLogicalNotArgs() {
        let arg = Expression.variable("x")
        let op = Expression.call(name: "not", arguments: [arg])
        assertNoThrow {
            let result = try op.evaluate(context: ["x": [.booleanValue(false)]])
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    // Arithmetic.

    func test_plus_oneArgs_throws() {
        let plus = Expression.call(name: "+", arguments: [.integerValue(5)])
        XCTAssertThrowsError(try plus.evaluate())
    }

    func test_plus_manyArgs_throws() {
        let plus = Expression.call(name: "+", arguments: [.integerValue(5), .integerValue(4), .integerValue(9)])
        XCTAssertThrowsError(try plus.evaluate())
    }

    func test_plus_twoArgs() {
        let plus = Expression.call(name: "+", arguments: [.integerValue(9), .integerValue(5)])
        assertNoThrow {
            let result = try plus.evaluate()
            XCTAssertEqual(Expression.integerValue(14), result)
        }
    }

    func test_minus_oneArgs_throws() {
        let minus = Expression.call(name: "-", arguments: [.integerValue(5)])
        XCTAssertThrowsError(try minus.evaluate())
    }

    func test_minus_manyArgs_throws() {
        let minus = Expression.call(name: "-", arguments: [.integerValue(2), .integerValue(3), .integerValue(4)])
        XCTAssertThrowsError(try minus.evaluate())
    }

    func test_minus_twoArgs() {
        let minus = Expression.call(name: "-", arguments: [.integerValue(9), .integerValue(5)])
        assertNoThrow {
            let result = try minus.evaluate()
            XCTAssertEqual(Expression.integerValue(4), result)
        }
    }

    func test_times_oneArgs_throws() {
        let times = Expression.call(name: "*", arguments: [.integerValue(5)])
        XCTAssertThrowsError(try times.evaluate())
    }

    func test_times_manyArgs_throws() {
        let times = Expression.call(name: "*", arguments: [.integerValue(5), .integerValue(3), .integerValue(2)])
        XCTAssertThrowsError(try times.evaluate())
    }

    func test_times_twoArgs() {
        let times = Expression.call(name: "*", arguments: [.integerValue(9), .integerValue(5)])
        assertNoThrow {
            let result = try times.evaluate()
            XCTAssertEqual(Expression.integerValue(45), result)
        }
    }

    func test_dividedBy_oneArg_throws() {
        let dividedBy = Expression.call(name: "/", arguments: [.integerValue(10)])
        XCTAssertThrowsError(try dividedBy.evaluate())
    }

    func test_dividedBy_manyArgs_throws() {
        let dividedBy = Expression.call(name: "/", arguments: [.integerValue(10), .integerValue(2), .integerValue(4)])
        XCTAssertThrowsError(try dividedBy.evaluate())
    }

    func test_dividedBy_twoArgs() {
        let dividedBy = Expression.call(name: "/", arguments: [.integerValue(10), .integerValue(5)])
        assertNoThrow {
            let result = try dividedBy.evaluate()
            XCTAssertEqual(Expression.floatValue(2.0), result)
        }
    }

    func test_modulo_oneArg_throws() {
        let modulo = Expression.call(name: "%", arguments: [.integerValue(10)])
        XCTAssertThrowsError(try modulo.evaluate())
    }

    func test_module_manyArgs_throws() {
        let module = Expression.call(name: "%", arguments: [.integerValue(10), .integerValue(2), .integerValue(4)])
        XCTAssertThrowsError(try module.evaluate())
    }

    func test_module_twoArgs() {
        let modulo = Expression.call(name: "%", arguments: [.integerValue(10), .integerValue(3)])
        assertNoThrow {
            let result = try modulo.evaluate()
            XCTAssertEqual(Expression.integerValue(1), result)
        }
    }

    // Relational.

    func test_lessThan_leftLessThanRight_returnsTrue() {
        let lessThan = Expression.call(name: "<", arguments: [.integerValue(2), .integerValue(3)])
        assertNoThrow {
            let result = try lessThan.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func test_lessThan_rightLessThanLeft_returnsFalse() {
        let lessThan = Expression.call(name: "<", arguments: [.integerValue(4), .integerValue(3)])
        assertNoThrow {
            let result = try lessThan.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_greaterThan_leftLessThanRight_returnsFalse() {
        let gt = Expression.call(name: ">", arguments: [.integerValue(2), .integerValue(3)])
        assertNoThrow {
            let result = try gt.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_greaterThan_rightLessThanLeft_returnsTrue() {
        let gt = Expression.call(name: ">", arguments: [.integerValue(4), .integerValue(3)])
        assertNoThrow {
            let result = try gt.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func test_lessThanOrEqual_leftLessThanRight_returnsTrue() {
        let lte = Expression.call(name: "<=", arguments: [.integerValue(2), .integerValue(3)])
        assertNoThrow {
            let result = try lte.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func test_lessThanOrEqual_rightLessThanLeft_returnsFalse() {
        let lte = Expression.call(name: "<=", arguments: [.integerValue(4), .integerValue(3)])
        assertNoThrow {
            let result = try lte.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_lessThanOrEqual_equal_returnsTrue() {
        let lte = Expression.call(name: "<=", arguments: [.integerValue(3), .integerValue(3)])
        assertNoThrow {
            let result = try lte.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func test_greaterThanOrEqual_leftLessThanRight_returnsFalse() {
        let gte = Expression.call(name: ">=", arguments: [.integerValue(2), .integerValue(3)])
        assertNoThrow {
            let result = try gte.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_greaterThanOrEqual_rightLessThanLeft_returnsTrue() {
        let gte = Expression.call(name: ">=", arguments: [.integerValue(4), .integerValue(3)])
        assertNoThrow {
            let result = try gte.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func test_greaterThanOrEqual_equal_returnsTrue() {
        let gte = Expression.call(name: ">=", arguments: [.integerValue(3), .integerValue(3)])
        assertNoThrow {
            let result = try gte.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    // Logical (binary).

    func test_equalTo_equal_returnsTrue() {
        let eq = Expression.call(name: "eq", arguments: [.integerValue(3), .integerValue(3)])
        assertNoThrow {
            let result = try eq.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func test_equalTo_notEqual_returnsFalse() {
        let eq = Expression.call(name: "eq", arguments: [.integerValue(2), .integerValue(3)])
        assertNoThrow {
            let result = try eq.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_notEqualTo_equal_returnsFalse() {
        let neq = Expression.call(name: "neq", arguments: [.integerValue(3), .integerValue(3)])
        assertNoThrow {
            let result = try neq.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_notEqualTo_notEqual_returnsTrue() {
        let neq = Expression.call(name: "neq", arguments: [.integerValue(2), .integerValue(3)])
        assertNoThrow {
            let result = try neq.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func test_and_true_true_returnsTrue() {
        let and = Expression.call(name: "and", arguments: [.booleanValue(true), .booleanValue(true)])
        assertNoThrow {
            let result = try and.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func test_and_true_false_returnsFalse() {
        let and = Expression.call(name: "and", arguments: [.booleanValue(true), .booleanValue(false)])
        assertNoThrow {
            let result = try and.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_and_false_true_returnsFalse() {
        let and = Expression.call(name: "and", arguments: [.booleanValue(false), .booleanValue(true)])
        assertNoThrow {
            let result = try and.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_and_false_false_returnsFalse() {
        let and = Expression.call(name: "and", arguments: [.booleanValue(false), .booleanValue(false)])
        assertNoThrow {
            let result = try and.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_or_true_true_returnsTrue() {
        let or = Expression.call(name: "or", arguments: [.booleanValue(true), .booleanValue(true)])
        assertNoThrow {
            let result = try or.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func test_or_true_false_returnsTrue() {
        let or = Expression.call(name: "or", arguments: [.booleanValue(true), .booleanValue(false)])
        assertNoThrow {
            let result = try or.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func test_or_false_true_returnsTrue() {
        let or = Expression.call(name: "or", arguments: [.booleanValue(false), .booleanValue(true)])
        assertNoThrow {
            let result = try or.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func test_or_false_false_returnsFalse() {
        let or = Expression.call(name: "or", arguments: [.booleanValue(false), .booleanValue(false)])
        assertNoThrow {
            let result = try or.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    // Logical (unary).

    func test_not_true_returnsFalse() {
        let not = Expression.call(name: "not", arguments: [.booleanValue(true)])
        assertNoThrow {
            let result = try not.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }

    func test_not_false_returnsTrue() {
        let not = Expression.call(name: "not", arguments: [.booleanValue(false)])
        assertNoThrow {
            let result = try not.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }
}
