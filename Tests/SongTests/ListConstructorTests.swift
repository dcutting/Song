import XCTest
import Song

class ListConstructorTests: XCTestCase {

    func testDescription() {
        let listConstructor = Expression.listConstructor(.integerValue(9), .variable("xs"))
        XCTAssertEqual("[9|xs]", "\(listConstructor)")
    }

    func testEquatable_same_returnsTrue() {
        let left = Expression.listConstructor(.integerValue(1), .list([.integerValue(2)]))
        let right = Expression.listConstructor(.integerValue(1), .list([.integerValue(2)]))
        XCTAssertEqual(left, right)
    }

    func testEquatable_different_returnsFalse() {
        let left = Expression.listConstructor(.integerValue(1), .list([]))
        let right = Expression.listConstructor(.integerValue(1), .list([.integerValue(2)]))
        XCTAssertNotEqual(left, right)
    }
}
