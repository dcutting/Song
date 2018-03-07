import XCTest
import Song

class CharacterTests: XCTestCase {

    func test_description() {
        let char = Expression.char("A")
        XCTAssertEqual("'A'", "\(char)")
    }

    func test_description_escaped() {
        let char = Expression.char("\'")
        XCTAssertEqual("'\\''", "\(char)")
    }

    func testEvaluate() {
        assertNoThrow {
            let char = Expression.char("$")
            XCTAssertEqual(char, try char.evaluate())
        }
    }

    func test_eq_equal_returnsYes() {
        assertNoThrow {
            let call = Expression.call("Eq", [.char("A"), .char("A")])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
    }

    func test_eq_unequal_returnsNo() {
        assertNoThrow {
            let call = Expression.call("Eq", [.char("A"), .char("Z")])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
    }

    func test_notEq_equal_returnsNo() {
        assertNoThrow {
            let call = Expression.call("Neq", [.char("A"), .char("A")])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
    }

    func test_notEq_unequal_returnsYes() {
        assertNoThrow {
            let call = Expression.call("Neq", [.char("A"), .char("Z")])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
    }
}
