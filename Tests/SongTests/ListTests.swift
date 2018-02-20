import XCTest
import Song

class ListTests: XCTestCase {

    func testDescription_emptyList() {
        let emptyList = Expression.list([])
        XCTAssertEqual("[]", "\(emptyList)")
    }

    func testDescription_nonEmptyList() {
        let list = Expression.list([.integerValue(4), .booleanValue(false)])
        XCTAssertEqual("[4, no]", "\(list)")
    }
}
