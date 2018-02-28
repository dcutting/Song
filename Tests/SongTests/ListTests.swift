import XCTest
import Song

class ListTests: XCTestCase {

    func testDescription_emptyList() {
        let emptyList = Expression.list([])
        XCTAssertEqual("[]", "\(emptyList)")
    }

    func testDescription_nonEmptyList() {
        let list = Expression.list([.integerValue(4), .booleanValue(false)])
        XCTAssertEqual("[4, No]", "\(list)")
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

    func test_evaluate_emptyList_returnsEmptyList() {
        XCTAssertEqual(Expression.list([]), Expression.list([]))
    }

    func test_evaluate_nonEmptyList_returnsListOfAllEvaluatedItems() {
        let list = Expression.list([
            .call(name: "+", arguments: [.integerValue(2), .integerValue(3)]),
            .variable("x")
            ])
        assertNoThrow {
            let actual = try list.evaluate(context: ["x": [.booleanValue(false)]])
            let expected = Expression.list([
                .integerValue(5),
                .booleanValue(false)
                ])
            XCTAssertEqual(expected, actual)
        }
    }

    func test_evaluate_concatenateLists() {
        let left = Expression.list([.integerValue(1), .integerValue(2)])
        let right = Expression.list([.integerValue(3), .integerValue(4)])
        let call = Expression.call(name: "+", arguments: [left, right])
        assertNoThrow {
            let actual = try call.evaluate()
            let expected = Expression.list([.integerValue(1), .integerValue(2), .integerValue(3), .integerValue(4)])
            XCTAssertEqual(expected, actual)
        }
    }

    func test_evaluate_equalLists() {
        let left = Expression.list([.integerValue(1), .integerValue(2)])
        let right = Expression.list([.integerValue(1), .integerValue(2)])

        assertNoThrow {
            let call = Expression.call(name: "Eq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(true), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call(name: "Neq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(false), try call.evaluate())
        }
    }

    func test_evaluate_unequalLists() {
        let left = Expression.list([.integerValue(1)])
        let right = Expression.list([.integerValue(1), .integerValue(2)])

        assertNoThrow {
            let call = Expression.call(name: "Eq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(false), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call(name: "Neq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(true), try call.evaluate())
        }
    }

    func test_eq_containsFloats_throws() {
        let a = Expression.list([.floatValue(5.0)])
        let b = Expression.list([.floatValue(5.0)])
        let eq = Expression.call(name: "Eq", arguments: [a, b])
        XCTAssertThrowsError(try eq.evaluate())
    }

    func test_evaluate_equalNestedLists() {
        let left = Expression.list([.list([.integerValue(9), .booleanValue(false)]), .integerValue(1), .stringValue("ok")])
        let right = Expression.list([.list([.integerValue(9), .booleanValue(false)]), .integerValue(1), .stringValue("ok")])

        assertNoThrow {
            let call = Expression.call(name: "Eq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(true), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call(name: "Neq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(false), try call.evaluate())
        }
    }

    func test_evaluate_almostEqualNestedLists() {
        let left = Expression.list([.list([.integerValue(8), .booleanValue(false)]), .integerValue(1), .stringValue("ok")])
        let right = Expression.list([.list([.integerValue(9), .booleanValue(false)]), .integerValue(1), .stringValue("ok")])

        assertNoThrow {
            let call = Expression.call(name: "Eq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(false), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call(name: "Neq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(true), try call.evaluate())
        }
    }

    func test_evaluate_unequalNestedLists() {
        let left = Expression.list([.list([.booleanValue(false)]), .integerValue(1), .stringValue("ok")])
        let right = Expression.list([.list([.integerValue(9), .booleanValue(false)]), .stringValue("ok")])

        assertNoThrow {
            let call = Expression.call(name: "Eq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(false), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call(name: "Neq", arguments: [left, right])
            XCTAssertEqual(Expression.booleanValue(true), try call.evaluate())
        }
    }
}
