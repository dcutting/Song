import XCTest
import Song

class StringTests: XCTestCase {
    
    func test_description_withoutQuotes() {
        let string = Expression.stringValue("hello")
        let actual = "\(string)"
        XCTAssertEqual("\"hello\"", actual)
    }

    func test_description_withQuotes_escapesQuotes() {
        let string = Expression.stringValue("\"Hello\" world")
        let actual = "\(string)"
        XCTAssertEqual("\"\\\"Hello\\\" world\"", actual)
    }

    func test_description_withBackslash_escapesBackslash() {
        let string = Expression.stringValue("a\\backslash")
        let actual = "\(string)"
        XCTAssertEqual("\"a\\backslash\"", actual)
    }

    func test_evaluate() {
        assertNoThrow {
            let string = Expression.stringValue("hello")
            let actual = try string.evaluate()
            XCTAssertEqual(string, actual)
        }
    }

    func test_evaluate_concatenateStrings() {
        assertNoThrow {
            let left = Expression.stringValue("hello")
            let right = Expression.stringValue(" world")
            let call = Expression.call(name: "+", arguments: [left, right])
            let actual = try call.evaluate()
            let expected = Expression.stringValue("hello world")
            XCTAssertEqual(expected, actual)
        }
    }

    func test_evaluate_equalStrings() {
        let left = Expression.stringValue("hello world")
        let right = Expression.stringValue("hello world")

        assertNoThrow {
            let call = Expression.call(name: "Eq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(true), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call(name: "Neq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(false), try call.evaluate())
        }
    }

    func test_evaluate_unequalStrings() {
        let left = Expression.stringValue("hello world")
        let right = Expression.stringValue("goodbye world")

        assertNoThrow {
            let call = Expression.call(name: "Eq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(false), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call(name: "Neq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(true), try call.evaluate())
        }
    }
}
