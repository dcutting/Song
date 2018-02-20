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

    func testEquatable_same_returnsTrue() {
        let left = Expression.list([.integerValue(1), .integerValue(2), .integerValue(3)])
        let right = Expression.list([.integerValue(1), .integerValue(2), .integerValue(3)])
        XCTAssertEqual(left, right)
    }

    func testEquatable_different_returnsFalse() {
        let left = Expression.list([.integerValue(2), .integerValue(1), .integerValue(3)])
        let right = Expression.list([.integerValue(1), .integerValue(2), .integerValue(3)])
        XCTAssertNotEqual(left, right)
    }
}
