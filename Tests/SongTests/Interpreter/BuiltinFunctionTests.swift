import XCTest
import SongLang

class BuiltinFunctionTests: XCTestCase {

    // Invalid types.

    func test_invalidArgumentTypes() {
        XCTAssertThrowsError(try Expression.call("*", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("/", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Mod", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Div", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("+", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("-", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("<", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call(">", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("<=", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call(">=", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Eq", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Neq", [.int(5), .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("And", [.yes, .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Or", [.yes, .string("hi")]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Not", [.string("hi")]).evaluate(context: .empty))
    }

    // Invalid number of arguments.

    func test_invalidArgumentCount() {
        XCTAssertThrowsError(try Expression.call("*", [.int(1)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("*", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("/", [.int(1)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("/", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Mod", [.int(1)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Mod", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Div", [.int(1)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Div", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("+", [.int(1)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("+", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("-", []).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("-", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("<", [.int(1)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("<", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call(">", [.int(1)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call(">", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("<=", [.int(1)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("<=", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call(">=", [.int(1)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call(">=", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Eq", [.int(1)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Eq", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Neq", [.int(1)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Neq", [.int(1), .int(2), .int(3)]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("And", [.yes]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("And", [.yes, .yes, .yes]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Or", [.yes]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Or", [.yes, .yes, .yes]).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Not", []).evaluate(context: .empty))
        XCTAssertThrowsError(try Expression.call("Not", [.yes, .yes]).evaluate(context: .empty))
    }

    // Description

    func test_description() {
        let expr = Expression.builtIn(.equal)
        XCTAssertEqual("Eq", expr.description)
    }

    // Evaluates arguments.

    func test_evaluatesArguments() {
        let first = Expression.name("x")
        let second = Expression.name("y")
        let context: Context = Context.builtIns.extend(with: ["x": .int(9), "y": .int(5)])

        assertNoThrow {
            let op = try Expression.call("*", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.int(45), op)
        }

        assertNoThrow {
            let op = try Expression.call("/", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.float(1.8), op)
        }

        assertNoThrow {
            let op = try Expression.call("%", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.int(4), op)
        }

        assertNoThrow {
            let op = try Expression.call("Div", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.int(1), op)
        }

        assertNoThrow {
            let op = try Expression.call("+", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.int(14), op)
        }

        assertNoThrow {
            let op = try Expression.call("-", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.int(4), op)
        }

        assertNoThrow {
            let op = try Expression.call("-", [first]).evaluate(context: context)
            XCTAssertEqual(Expression.int(-9), op)
        }

        assertNoThrow {
            let op = try Expression.call("<", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.no, op)
        }

        assertNoThrow {
            let op = try Expression.call(">", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.yes, op)
        }

        assertNoThrow {
            let op = try Expression.call("<=", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.no, op)
        }

        assertNoThrow {
            let op = try Expression.call(">=", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.yes, op)
        }

        assertNoThrow {
            let op = try Expression.call("Eq", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.no, op)
        }

        assertNoThrow {
            let op = try Expression.call("Neq", [first, second]).evaluate(context: context)
            XCTAssertEqual(Expression.yes, op)
        }

        assertNoThrow {
            let op = Expression.call("And", [first, second])
            let result = try op.evaluate(context: context.extend(with: ["x": .yes, "y": .no]))
            XCTAssertEqual(Expression.no, result)
        }

        assertNoThrow {
            let op = Expression.call("Or", [first, second])
            let result = try op.evaluate(context: context.extend(with: ["x": .no, "y": .yes]))
            XCTAssertEqual(Expression.yes, result)
        }

        assertNoThrow {
            let op = Expression.call("Not", [first])
            let result = try op.evaluate(context: context.extend(with: ["x": .no]))
            XCTAssertEqual(Expression.yes, result)
        }
    }
}
