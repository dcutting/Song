import XCTest
@testable import Song

class ContextTests: XCTestCase {

    func test_isEqual_empty_returnsTrue() {
        let left = Context()
        let right = Context()
        XCTAssertTrue(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func test_isEqual_simple_same_returnsTrue() {
        let left: Context = ["a": .string("hi"), "b": .yes]
        let right: Context = ["a": .string("hi"), "b": .yes]
        XCTAssertTrue(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func test_isEqual_simple_different_returnsFalse() {
        let left: Context = ["a": .string("hi")]
        let right: Context = ["a": .string("bye")]
        XCTAssertFalse(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func test_isEqual_simple_differentKeys_returnsFalse() {
        let left: Context = ["a": .int(4)]
        let right: Context = ["b": .int(4)]
        XCTAssertFalse(Song.isEqual(lhsContext: left, rhsContext: right))
    }

    func test_call_contextsAreNotDynamicallyScoped() {
        let foo = Function(name: "foo", patterns: [.name("x")], when: .yes, body: .name("n"))
        let bar = Function(name: "bar", patterns: [.name("n")], when: .yes, body: .call("foo", [.name("n")]))
        let context = try! declareSubfunctions([foo, bar])

        let call = Expression.call("bar", [.int(5)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }
}
