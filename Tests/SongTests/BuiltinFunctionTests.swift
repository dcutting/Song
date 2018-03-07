import XCTest
import Song

class BuiltinFunctionTests: XCTestCase {

    // Invalid types.

    func test_invalidArgumentTypes() {
        XCTAssertThrowsError(try Expression.call(name: "*", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "/", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Mod", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Div", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "+", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "-", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "<", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: ">", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "<=", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: ">=", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Eq", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Neq", arguments: [.integerValue(5), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "And", arguments: [.bool(true), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Or", arguments: [.bool(true), .stringValue("hi")]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Not", arguments: [.stringValue("hi")]).evaluate())
    }

    // Invalid number of arguments.

    func test_invalidArgumentCount() {
        XCTAssertThrowsError(try Expression.call(name: "*", arguments: [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "*", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "/", arguments: [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "/", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Mod", arguments: [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Mod", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Div", arguments: [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Div", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "+", arguments: [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "+", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "-", arguments: []).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "-", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "<", arguments: [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "<", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: ">", arguments: [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: ">", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "<=", arguments: [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "<=", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: ">=", arguments: [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: ">=", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Eq", arguments: [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Eq", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Neq", arguments: [.integerValue(1)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Neq", arguments: [.integerValue(1), .integerValue(2), .integerValue(3)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "And", arguments: [.bool(true)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "And", arguments: [.bool(true), .bool(true), .bool(true)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Or", arguments: [.bool(true)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Or", arguments: [.bool(true), .bool(true), .bool(true)]).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Not", arguments: []).evaluate())
        XCTAssertThrowsError(try Expression.call(name: "Not", arguments: [.bool(true), .bool(true)]).evaluate())
    }

    // Evaluates arguments.

    func test_evaluatesArguments() {
        let first = Expression.variable("x")
        let second = Expression.variable("y")
        let context: Context = ["x": .integerValue(9), "y": .integerValue(5)]

        assertNoThrow {
            let op = try Expression.call(name: "*", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(45), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: "/", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.floatValue(1.8), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: "Mod", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(4), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: "Div", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(1), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: "+", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(14), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: "-", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(4), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: "-", arguments: [first]).evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(-9), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: "<", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(false), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: ">", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(true), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: "<=", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(false), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: ">=", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(true), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: "Eq", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(false), op)
        }

        assertNoThrow {
            let op = try Expression.call(name: "Neq", arguments: [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.bool(true), op)
        }

        assertNoThrow {
            let op = Expression.call(name: "And", arguments: [first, second])
            let result = try op.evaluate(context: ["x": .bool(true), "y": .bool(false)])
            XCTAssertEqual(Expression.bool(false), result)
        }

        assertNoThrow {
            let op = Expression.call(name: "Or", arguments: [first, second])
            let result = try op.evaluate(context: ["x": .bool(false), "y": .bool(true)])
            XCTAssertEqual(Expression.bool(true), result)
        }

        assertNoThrow {
            let op = Expression.call(name: "Not", arguments: [first])
            let result = try op.evaluate(context: ["x": .bool(false)])
            XCTAssertEqual(Expression.bool(true), result)
        }
    }
}
