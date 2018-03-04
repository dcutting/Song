import XCTest
import Song

class NumberConversionTests: XCTestCase {

    func test_number_int_returnsInt() {
        assertNoThrow {
            let input = "99"
            let call = Expression.call(name: "number", arguments: [.stringValue(input)])
            XCTAssertEqual(.integerValue(99), try call.evaluate())
        }
    }

    func test_number_expressionEvaluatingToInt_returnsInt() {
        assertNoThrow {
            let context: Context = ["x": .stringValue("-5")]
            let variable = Expression.variable("x")
            let call = Expression.call(name: "number", arguments: [variable])
            XCTAssertEqual(.integerValue(-5), try call.evaluate(context: context))
        }
    }

    func test_number_float_returnsFloat() {
        assertNoThrow {
            let input = "0.2"
            let call = Expression.call(name: "number", arguments: [.stringValue(input)])
            XCTAssertEqual(.floatValue(0.2), try call.evaluate())
        }
    }

    func test_number_invalidNumber_throws() {
        let input = "hello"
        let call = Expression.call(name: "number", arguments: [.stringValue(input)])
        XCTAssertThrowsError(try call.evaluate())
    }

    func test_number_invalidString_throws() {
        let input = Expression.list([.character("9"), .integerValue(99)]) // This is a list that doesn't contain only characters (i.e., not a string).
        let call = Expression.call(name: "number", arguments: [input])
        XCTAssertThrowsError(try call.evaluate())
    }

    func test_number_invalidType_throws() {
        let call = Expression.call(name: "number", arguments: [.integerValue(99)])
        XCTAssertThrowsError(try call.evaluate())
    }

    func test_number_missingArgument_throws() {
        let call = Expression.call(name: "number", arguments: [])
        XCTAssertThrowsError(try call.evaluate())
    }
}
