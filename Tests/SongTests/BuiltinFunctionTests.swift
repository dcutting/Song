import XCTest
import Song

class BuiltinFunctionTests: XCTestCase {

    // Invalid types.

    func test_invalidArgumentTypes() {
        XCTAssertThrowsError(try Expression.call("*", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("/", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("Mod", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("Div", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("+", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("-", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("<", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(">", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("<=", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(">=", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("Eq", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("Neq", [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("And", [.bool(true), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("Or", [.bool(true), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call("Not", [.stringValue("hi")]).evaluate())
    }

    // Invalid number of arguments.

    func test_invalidArgumentCount() {
        XCTAssertThrowsError(try Expression.call("*", [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call("*", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call("/", [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call("/", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call("Mod", [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call("Mod", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call("Div", [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call("Div", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call("+", [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call("+", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call("-", []).evaluate())
        XCTAssertThrowsError(try Expression.call("-", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call("<", [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call("<", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(">", [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(">", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call("<=", [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call("<=", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(">=", [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(">=", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call("Eq", [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call("Eq", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call("Neq", [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call("Neq", [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call("And", [.bool(true)]).evaluate())
        XCTAssertThrowsError(try Expression.call("And", [.bool(true), .bool(true), .bool(true)]).evaluate())
        XCTAssertThrowsError(try Expression.call("Or", [.bool(true)]).evaluate())
        XCTAssertThrowsError(try Expression.call("Or", [.bool(true), .bool(true), .bool(true)]).evaluate())
        XCTAssertThrowsError(try Expression.call("Not", []).evaluate())
        XCTAssertThrowsError(try Expression.call("Not", [.bool(true), .bool(true)]).evaluate())
    }

    // Evaluates arguments.

    func test_evaluatesArguments() {
        let first = Expression.variable("x")
        let second = Expression.variable("y")
        let context: Context = ["x": .integerValue(9), "y": .integerValue(5)]

        assertNoThrow {
            let op = try Expression.call("*", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(45), op)
        }

        assertNoThrow {
            let op = try Expression.call("/", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.floatValue(1.8), op)
        }

        assertNoThrow {
            let op = try Expression.call("Mod", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(4), op)
        }

        assertNoThrow {
            let op = try Expression.call("Div", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(1), op)
        }

        assertNoThrow {
            let op = try Expression.call("+", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(14), op)
        }

        assertNoThrow {
            let op = try Expression.call("-", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(4), op)
        }

        assertNoThrow {
            let op = try Expression.call("-", [first]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(-9), op)
        }

        assertNoThrow {
            let op = try Expression.call("<", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(false), op)
        }

        assertNoThrow {
            let op = try Expression.call(">", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(true), op)
        }

        assertNoThrow {
            let op = try Expression.call("<=", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(false), op)
        }

        assertNoThrow {
            let op = try Expression.call(">=", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(true), op)
        }

        assertNoThrow {
            let op = try Expression.call("Eq", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(false), op)
        }

        assertNoThrow {
            let op = try Expression.call("Neq", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(true), op)
        }

        assertNoThrow {
            let op = Expression.call("And", [first, second])
            let result = try op.evaluate(context: ["x": .bool(true), "y": .bool(false)])
            XCTAssertEqual(Expression.bool(false), result)
        }

        assertNoThrow {
            let op = Expression.call("Or", [first, second])
            let result = try op.evaluate(context: ["x": .bool(false), "y": .bool(true)])
            XCTAssertEqual(Expression.bool(true), result)
        }

        assertNoThrow {
            let op = Expression.call("Not", [first])
            let result = try op.evaluate(context: ["x": .bool(false)])
            XCTAssertEqual(Expression.bool(true), result)
        }
    }
}
