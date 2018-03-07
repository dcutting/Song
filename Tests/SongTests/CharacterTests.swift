import XCTest
import Song

class CharacterTests: XCTestCase {

    func test_description() {
        let char = Expression.character("A")
        XCTAssertEqual("'A'", "\(char)")
    }

    func test_description_escaped() {
        let char = Expression.character("\'")
        XCTAssertEqual("'\\''", "\(char)")
    }

    func testEvaluate() {
        assertNoThrow {
            let char = Expression.character("$")
            XCTAssertEqual(char, try char.evaluate())
        }
    }

    func test_eq_equal_returnsYes() {
        assertNoThrow {
            let call = Expression.call(name: "Eq", arguments: [.character("A"), .character("A")])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
    }

    func test_eq_unequal_returnsNo() {
        assertNoThrow {
            let call = Expression.call(name: "Eq", arguments: [.character("A"), .character("Z")])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
    }

    func test_notEq_equal_returnsNo() {
        assertNoThrow {
            let call = Expression.call(name: "Neq", arguments: [.character("A"), .character("A")])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
    }

    func test_notEq_unequal_returnsYes() {
        assertNoThrow {
            let call = Expression.call(name: "Neq", arguments: [.character("A"), .character("Z")])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
    }
}
