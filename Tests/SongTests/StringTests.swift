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

    func test_evaluate() {
        assertNoThrow {
            let string = Expression.stringValue("hello")
            let actual = try string.evaluate()
            XCTAssertEqual(string, actual)
        }
    }
}
