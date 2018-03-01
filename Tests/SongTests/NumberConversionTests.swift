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
}
