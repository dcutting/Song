import XCTest
import Song

class OutTests: XCTestCase {

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
        XCTAssertEqual("foo() when yes = 99", actual)
    }

    func testOut_integerValue() {
        let string = Expression.integerValue(5)
        let actual = string.out()
        XCTAssertEqual("5", actual)
    }
}
