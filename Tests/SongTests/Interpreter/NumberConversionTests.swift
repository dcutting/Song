import XCTest
import SongLang

class NumberConversionTests: XCTestCase {

    func test_number_int_returnsInt() {
        assertNoThrow {
            let input = "99"
            let call = Expression.call("number", [.string(input)])
            XCTAssertEqual(.int(99), try call.evaluate(context: .builtIns))
        }
    }

    func test_number_expressionEvaluatingToInt_returnsInt() {
        assertNoThrow {
            let context = Context.builtIns.extend(name: "x", value: .string("-5"))
            let variable = Expression.name("x")
            let call = Expression.call("number", [variable])
            XCTAssertEqual(.int(-5), try call.evaluate(context: context))
        }
    }

    func test_number_float_returnsFloat() {
        assertNoThrow {
            let input = "0.2"
            let call = Expression.call("number", [.string(input)])
            XCTAssertEqual(.float(0.2), try call.evaluate(context: .builtIns))
        }
    }

    func test_number_invalidNumber_throws() {
        let input = "hello"
        let call = Expression.call("number", [.string(input)])
        XCTAssertThrowsError(try call.evaluate(context: .empty))
    }

    func test_number_invalidString_throws() {
        let input = Expression.list([.char("9"), .int(99)]) // This is a list that doesn't contain only characters (i.e., not a string).
        let call = Expression.call("number", [input])
        XCTAssertThrowsError(try call.evaluate(context: .empty))
    }

    func test_number_invalidType_throws() {
        let call = Expression.call("number", [.int(99)])
        XCTAssertThrowsError(try call.evaluate(context: .empty))
    }

    func test_number_missingArgument_throws() {
        let call = Expression.call("number", [])
        XCTAssertThrowsError(try call.evaluate(context: .empty))
    }
}
