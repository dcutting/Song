import XCTest
import Song

class OutTests: XCTestCase {

    func testOut_characterValue_doesNotIncludeQuotes() {
        let char = Expression.character("A")
        let actual = char.out()
        XCTAssertEqual("A", actual)
    }

    func testOut_stringValue_doesNotIncludeQuotes() {
        let string = Expression.stringValue("foo")
        let actual = string.out()
        XCTAssertEqual("foo", actual)
    }

    func testOut_closureValue_doesNotIncludeContext() {
        let subfunction = Subfunction(name: "foo", patterns: [], when: .booleanValue(true), body: .integerValue(99))
        let function = Expression.subfunction(subfunction)
        let context: Context = ["a": [.integerValue(5)]]
        let string = Expression.closure(closure: function, context: context)
        let actual = string.out()
        XCTAssertEqual("foo() When Yes = 99", actual)
    }

    func testOut_integerValue() {
        let string = Expression.integerValue(5)
        let actual = string.out()
        XCTAssertEqual("5", actual)
    }

    func test_evaluate_noArguments_emptyString() {
        assertNoThrow {
            let call = Expression.call(name: "out", arguments: [])
            XCTAssertEqual(Expression.stringValue(""), try call.evaluate())
        }
    }

    func test_evaluate_oneArgument_descriptionOfArgument() {
        assertNoThrow {
            let call = Expression.call(name: "out", arguments: [.integerValue(99)])
            XCTAssertEqual(Expression.stringValue("99"), try call.evaluate())
        }
    }

    func test_evaluate_multipleArguments_joinsWithSpace() {
        assertNoThrow {
            let call = Expression.call(name: "out", arguments: [.integerValue(99), .stringValue("is in"), .list([.booleanValue(true), .integerValue(99)])])
            XCTAssertEqual(Expression.stringValue("99 is in [Yes, 99]"), try call.evaluate())
        }
    }
}
