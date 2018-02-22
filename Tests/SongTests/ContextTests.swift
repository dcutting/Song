import XCTest
@testable import Song

class ContextTests: XCTestCase {

    func testIsEqual_empty_returnsTrue() {
        let left = Context()
        let right = Context()
        XCTAssertTrue(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func testIsEqual_simple_same_returnsTrue() {
        let left: Context = ["a": [.integerValue(4), .stringValue("hi")], "b": [.booleanValue(true)]]
        let right: Context = ["a": [.integerValue(4), .stringValue("hi")], "b": [.booleanValue(true)]]
        XCTAssertTrue(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func testIsEqual_simple_different_returnsFalse() {
        let left: Context = ["a": [.integerValue(4), .stringValue("hi")]]
        let right: Context = ["a": [.integerValue(4), .stringValue("bye")]]
        XCTAssertFalse(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func testIsEqual_simple_differentKeys_returnsFalse() {
        let left: Context = ["a": [.integerValue(4)]]
        let right: Context = ["b": [.integerValue(4)]]
        XCTAssertFalse(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func testIsEqual_deeper_same_returnsTrue() {
        let left: Context = ["a": [.constant(variable: .variable("x"), value: .stringValue("hi"))]]
        let right: Context = ["a": [.constant(variable: .variable("x"), value: .stringValue("hi"))]]
        XCTAssertTrue(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func testIsEqual_deeper_different_returnsFalse() {
        let left: Context = ["a": [.constant(variable: .variable("x"), value: .stringValue("hi"))]]
        let right: Context = ["a": [.constant(variable: .variable("x"), value: .stringValue("bye"))]]
        XCTAssertFalse(Song.isEqual(lhsContext: left, rhsContext: right))
    }
}
