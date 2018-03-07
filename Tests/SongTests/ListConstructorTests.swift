import XCTest
import Song

class ListConstructorTests: XCTestCase {

    func testDescription() {
        let listConstructor = Expression.listCons([.integerValue(9), .stringValue("hi")], .variable("xs"))
        XCTAssertEqual("[9, \"hi\"|xs]", "\(listConstructor)")
    }

    func testEquatable_same_returnsTrue() {
        let left = Expression.listCons([.integerValue(1), .integerValue(5)], .list([.integerValue(2)]))
        let right = Expression.listCons([.integerValue(1), .integerValue(5)], .list([.integerValue(2)]))
        XCTAssertEqual(left, right)
    }

    func testEquatable_different_returnsFalse() {
        let left = Expression.listCons([.integerValue(1), .integerValue(5)], .list([]))
        let right = Expression.listCons([.integerValue(1), .integerValue(5)], .list([.integerValue(2)]))
        XCTAssertNotEqual(left, right)
    }

    func test_evaluate_simple_constructsList() {
        let cons = Expression.listCons([.integerValue(1), .integerValue(2)], .list([.integerValue(3)]))
        assertNoThrow {
            let actual = try cons.evaluate()
            XCTAssertEqual(Expression.list([.integerValue(1), .integerValue(2), .integerValue(3)]), actual)
        }
    }

    func test_evaluate_emptyHeads_constructsList() {
        let cons = Expression.listCons([], .list([.integerValue(1)]))
        assertNoThrow {
            let actual = try cons.evaluate()
            XCTAssertEqual(Expression.list([.integerValue(1)]), actual)
        }
    }

    func test_evaluate_evaluatesHeadsAndTail() {
        let cons = Expression.listCons([.variable("x")], .list([.variable("y")]))
        assertNoThrow {
            let actual = try cons.evaluate(context: ["x": .stringValue("hi"), "y": .integerValue(1)])
            XCTAssertEqual(Expression.list([.stringValue("hi"), .integerValue(1)]), actual)
        }
    }

    func test_evaluate_tailNotAList_throws() {
        let cons = Expression.listCons([.integerValue(1)], .integerValue(2))
        XCTAssertThrowsError(try cons.evaluate())
    }
}
