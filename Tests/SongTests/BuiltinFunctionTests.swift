import XCTest
import Song

class BuiltinFunctionTests: XCTestCase {

    func test_nonIntegerValue_throws() {
        let plus = Expression.call(name: "+", arguments: [.integerValue(5), .stringValue("hi")])
        XCTAssertThrowsError(try plus.evaluate())
    }

    func test_evaluatesArgs() {
        let left = Expression.variable("x")
        let right = Expression.variable("y")
        let plus = Expression.call(name: "+", arguments: [left, right])
        assertNoThrow {
            let result = try plus.evaluate(context: ["x": [Expression.integerValue(9)], "y": [Expression.integerValue(5)]])
            XCTAssertEqual(Expression.integerValue(14), result)
        }
    }

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
            XCTAssertEqual(Expression.integerValue(2), result)
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
}
