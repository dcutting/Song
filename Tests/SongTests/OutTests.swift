import XCTest
import Song

class OutTests: XCTestCase {

    func testOut_stringValue_doesNotIncludeQuotes() {
        let string = Expression.stringValue("foo")
        let actual = string.out()
        XCTAssertEqual("foo", actual)
    }

    func testOut_integerValue() {
        let string = Expression.integerValue(5)
        let actual = string.out()
        XCTAssertEqual("5", actual)
    }
}
