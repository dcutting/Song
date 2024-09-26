import XCTest
import SongLang

class BoolTests: XCTestCase {

    func test_description_true() {
        XCTAssertEqual("Yes", "\(Expression.yes)")
    }
    
    func test_description_false() {
        XCTAssertEqual("No", "\(Expression.no)")
    }
    
    func test_evaluate_true() {
        assertNoThrow {
            XCTAssertEqual(Expression.yes, try Expression.yes.evaluate(context: .empty))
        }
    }
    
    func test_evaluate_false() {
        assertNoThrow {
            XCTAssertEqual(Expression.no, try Expression.no.evaluate(context: .empty))
        }
    }

    func test_eq_equal_returnsYes() {
        assertNoThrow {
            let call = Expression.call("Eq", [.yes, .yes])
            XCTAssertEqual(Expression.yes, try call.evaluate(context: .builtIns))
        }
    }

    func test_eq_unequal_returnsNo() {
        assertNoThrow {
            let call = Expression.call("Eq", [.no, .yes])
            XCTAssertEqual(Expression.no, try call.evaluate(context: .builtIns))
        }
    }

    func test_neq_equal_returnsNo() {
        assertNoThrow {
            let call = Expression.call("Neq", [.yes, .yes])
            XCTAssertEqual(Expression.no, try call.evaluate(context: .builtIns))
        }
    }

    func test_neq_unequal_returnsYes() {
        assertNoThrow {
            let call = Expression.call("Neq", [.no, .yes])
            XCTAssertEqual(Expression.yes, try call.evaluate(context: .builtIns))
        }
    }
}
