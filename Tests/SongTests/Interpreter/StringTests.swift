import XCTest
import SongLang

class StringTests: XCTestCase {

    func test_description_emptyString_returnsEmptyList() {
        let string = Expression.string("")
        XCTAssertEqual("[]", "\(string)")
    }

    func test_description_withoutQuotes() {
        let string = Expression.string("hello")
        let actual = "\(string)"
        XCTAssertEqual("\"hello\"", actual)
    }

    func test_description_withQuotes_escapesQuotes() {
        let string = Expression.string("\"Hello\" world")
        let actual = "\(string)"
        XCTAssertEqual("\"\\\"Hello\\\" world\"", actual)
    }

    func test_description_withBackslash_escapesBackslash() {
        let string = Expression.string("a\\backslash")
        let actual = "\(string)"
        XCTAssertEqual("\"a\\backslash\"", actual)
    }

    func test_evaluate() {
        assertNoThrow {
            let string = Expression.string("hello")
            let actual = try string.evaluate(context: .empty)
            XCTAssertEqual(string, actual)
        }
    }

    func test_evaluate_concatenateStrings() {
        assertNoThrow {
            let left = Expression.string("hello")
            let right = Expression.string(" world")
            let call = Expression.call("+", [left, right])
            let actual = try call.evaluate(context: .builtIns)
            let expected = Expression.string("hello world")
            XCTAssertEqual(expected, actual)
        }
    }

    func test_evaluate_equalStrings() {
        let left = Expression.string("hello world")
        let right = Expression.string("hello world")

        assertNoThrow {
            let call = Expression.call("Eq", [left, right])
            XCTAssertEqual(Expression.yes, try call.evaluate(context: .builtIns))
        }
        assertNoThrow {
            let call = Expression.call("Neq", [left, right])
            XCTAssertEqual(Expression.no, try call.evaluate(context: .builtIns))
        }
    }

    func test_evaluate_unequalStrings() {
        let left = Expression.string("hello world")
        let right = Expression.string("goodbye world")

        assertNoThrow {
            let call = Expression.call("Eq", [left, right])
            XCTAssertEqual(Expression.no, try call.evaluate(context: .builtIns))
        }
        assertNoThrow {
            let call = Expression.call("Neq", [left, right])
            XCTAssertEqual(Expression.yes, try call.evaluate(context: .builtIns))
        }
    }
}
