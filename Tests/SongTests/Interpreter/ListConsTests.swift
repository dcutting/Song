import XCTest
import Song

class ListConsTests: XCTestCase {

    func testDescription() {
        let listConstructor = Expression.cons([.int(9), .string("hi")], .name("xs"))
        XCTAssertEqual("[9, \"hi\"|xs]", "\(listConstructor)")
    }

    func testEquatable_same_returnsTrue() {
        let left = Expression.cons([.int(1), .int(5)], .list([.int(2)]))
        let right = Expression.cons([.int(1), .int(5)], .list([.int(2)]))
        XCTAssertEqual(left, right)
    }

    func testEquatable_different_returnsFalse() {
        let left = Expression.cons([.int(1), .int(5)], .list([]))
        let right = Expression.cons([.int(1), .int(5)], .list([.int(2)]))
        XCTAssertNotEqual(left, right)
    }

    func test_evaluate_simple_constructsList() {
        let cons = Expression.cons([.int(1), .int(2)], .list([.int(3)]))
        assertNoThrow {
            let actual = try cons.evaluate()
            XCTAssertEqual(Expression.list([.int(1), .int(2), .int(3)]), actual)
        }
    }

    func test_evaluate_emptyHeads_constructsList() {
        let cons = Expression.cons([], .list([.int(1)]))
        assertNoThrow {
            let actual = try cons.evaluate()
            XCTAssertEqual(Expression.list([.int(1)]), actual)
        }
    }

    func test_evaluate_evaluatesHeadsAndTail() {
        let cons = Expression.cons([.name("x")], .list([.name("y")]))
        assertNoThrow {
            let actual = try cons.evaluate(context: ["x": .string("hi"), "y": .int(1)])
            XCTAssertEqual(Expression.list([.string("hi"), .int(1)]), actual)
        }
    }

    func test_evaluate_tailNotAList_throws() {
        let cons = Expression.cons([.int(1)], .int(2))
        XCTAssertThrowsError(try cons.evaluate())
    }
}
