import XCTest
import SongLang

class CharTests: XCTestCase {

    func test_description() {
        let char = Expression.char("A")
        XCTAssertEqual("'A'", "\(char)")
    }

    func test_description_escapedQuote() {
        let char = Expression.char("\'")
        XCTAssertEqual("'\\''", "\(char)")
    }

    func test_description_backslash() {
        let char = Expression.char("\\")
        XCTAssertEqual("'\\'", "\(char)")
    }

    func test_evaluate() {
        assertNoThrow {
            let char = Expression.char("$")
            XCTAssertEqual(char, try char.evaluate(context: .empty))
        }
    }

    func test_eq_equal_returnsYes() {
        assertNoThrow {
            let call = Expression.call("Eq", [.char("A"), .char("A")])
            XCTAssertEqual(Expression.yes, try call.evaluate(context: .builtIns))
        }
    }

    func test_eq_unequal_returnsNo() {
        assertNoThrow {
            let call = Expression.call("Eq", [.char("A"), .char("Z")])
            XCTAssertEqual(Expression.no, try call.evaluate(context: .builtIns))
        }
    }

    func test_notEq_equal_returnsNo() {
        assertNoThrow {
            let call = Expression.call("Neq", [.char("A"), .char("A")])
            XCTAssertEqual(Expression.no, try call.evaluate(context: .builtIns))
        }
    }

    func test_notEq_unequal_returnsYes() {
        assertNoThrow {
            let call = Expression.call("Neq", [.char("A"), .char("Z")])
            XCTAssertEqual(Expression.yes, try call.evaluate(context: .builtIns))
        }
    }
}
