import XCTest
import Song

class StringConversionTests: XCTestCase {

    func test_strings() {
        assertNoThrow {
            let string = Expression.call("string", [.int(45), .bool(true), .string("ok")])
            XCTAssertEqual(Expression.string("45 Yes ok"), try string.evaluate())
        }
    }
}
