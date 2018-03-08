import XCTest
@testable import Song

class ContextTests: XCTestCase {

    func testIsEqual_empty_returnsTrue() {
        let left = Context()
        let right = Context()
        XCTAssertTrue(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func testIsEqual_simple_same_returnsTrue() {
        let left: Context = ["a": .string("hi"), "b": .bool(true)]
        let right: Context = ["a": .string("hi"), "b": .bool(true)]
        XCTAssertTrue(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func testIsEqual_simple_different_returnsFalse() {
        let left: Context = ["a": .string("hi")]
        let right: Context = ["a": .string("bye")]
        XCTAssertFalse(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func testIsEqual_simple_differentKeys_returnsFalse() {
        let left: Context = ["a": .int(4)]
        let right: Context = ["b": .int(4)]
        XCTAssertFalse(Song.isEqual(lhsContext: left, rhsContext: right))
    }
}
