import XCTest
import Song

class ListTests: XCTestCase {

    func test_description_emptyList() {
        let emptyList = Expression.list([])
        XCTAssertEqual("[]", "\(emptyList)")
    }

    func test_description_nonEmptyList() {
        let list = Expression.list([.int(4), .bool(false)])
        XCTAssertEqual("[4, No]", "\(list)")
    }

    func test_eq_same_returnsTrue() {
        let left = Expression.list([.int(1), .int(2), .int(3)])
        let right = Expression.list([.int(1), .int(2), .int(3)])
        XCTAssertEqual(left, right)
    }

    func test_eq_different_returnsFalse() {
        let left = Expression.list([.int(2), .int(1), .int(3)])
        let right = Expression.list([.int(1), .int(2), .int(3)])
        XCTAssertNotEqual(left, right)
    }

    func test_evaluate_emptyList_returnsEmptyList() {
        XCTAssertEqual(Expression.list([]), Expression.list([]))
    }

    func test_evaluate_nonEmptyList_returnsListOfAllEvaluatedItems() {
        let list = Expression.list([
            .call("+", [.int(2), .int(3)]),
            .name("x")
            ])
        assertNoThrow {
            let actual = try list.evaluate(context: ["x": .bool(false)])
            let expected = Expression.list([
                .int(5),
                .bool(false)
                ])
            XCTAssertEqual(expected, actual)
        }
    }

    func test_evaluate_concatenateLists() {
        let left = Expression.list([.int(1), .int(2)])
        let right = Expression.list([.int(3), .int(4)])
        let call = Expression.call("+", [left, right])
        assertNoThrow {
            let actual = try call.evaluate()
            let expected = Expression.list([.int(1), .int(2), .int(3), .int(4)])
            XCTAssertEqual(expected, actual)
        }
    }

    func test_evaluate_equalLists() {
        let left = Expression.list([.int(1), .int(2)])
        let right = Expression.list([.int(1), .int(2)])

        assertNoThrow {
            let call = Expression.call("Eq", [left, right])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call("Neq", [left, right])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
    }

    func test_evaluate_unequalLists() {
        let left = Expression.list([.int(1)])
        let right = Expression.list([.int(1), .int(2)])

        assertNoThrow {
            let call = Expression.call("Eq", [left, right])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call("Neq", [left, right])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
    }

    func test_eq_containsFloats_throws() {
        let a = Expression.list([.float(5.0)])
        let b = Expression.list([.float(5.0)])
        let eq = Expression.call("Eq", [a, b])
        XCTAssertThrowsError(try eq.evaluate())
    }

    func test_evaluate_equalNestedLists() {
        let left = Expression.list([.list([.int(9), .bool(false)]), .int(1), .string("ok")])
        let right = Expression.list([.list([.int(9), .bool(false)]), .int(1), .string("ok")])

        assertNoThrow {
            let call = Expression.call("Eq", [left, right])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call("Neq", [left, right])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
    }

    func test_evaluate_almostEqualNestedLists() {
        let left = Expression.list([.list([.int(8), .bool(false)]), .int(1), .string("ok")])
        let right = Expression.list([.list([.int(9), .bool(false)]), .int(1), .string("ok")])

        assertNoThrow {
            let call = Expression.call("Eq", [left, right])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call("Neq", [left, right])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
    }

    func test_evaluate_unequalNestedLists() {
        let left = Expression.list([.list([.bool(false)]), .int(1), .string("ok")])
        let right = Expression.list([.list([.int(9), .bool(false)]), .string("ok")])

        assertNoThrow {
            let call = Expression.call("Eq", [left, right])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
        assertNoThrow {
            let call = Expression.call("Neq", [left, right])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
    }
}
