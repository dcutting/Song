import XCTest
import SongLang

class StringConversionTests: XCTestCase {

    func test_strings() {
        assertNoThrow {
            let string = Expression.call("string", [.int(45), .yes, .string("ok")])
            XCTAssertEqual(Expression.string("45 Yes ok"), try string.evaluate())
        }
    }
}
