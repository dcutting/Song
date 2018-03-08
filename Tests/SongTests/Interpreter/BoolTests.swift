import XCTest
import Song

class BoolTests: XCTestCase {
    
    let trueBool = Expression.bool(true)
    let falseBool = Expression.bool(false)
    
    func test_description_true() {
        XCTAssertEqual("Yes", "\(trueBool)")
    }
    
    func test_description_false() {
        XCTAssertEqual("No", "\(falseBool)")
    }
    
    func test_evaluate_true() {
        assertNoThrow {
            XCTAssertEqual(trueBool, try trueBool.evaluate())
        }
    }
    
    func test_evaluate_false() {
        assertNoThrow {
            XCTAssertEqual(falseBool, try falseBool.evaluate())
        }
    }

    func test_eq_equal_returnsYes() {
        assertNoThrow {
            let call = Expression.call("Eq", [trueBool, trueBool])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
    }

    func test_eq_unequal_returnsNo() {
        assertNoThrow {
            let call = Expression.call("Eq", [falseBool, trueBool])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
    }

    func test_neq_equal_returnsNo() {
        assertNoThrow {
            let call = Expression.call("Neq", [trueBool, trueBool])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
    }

    func test_neq_unequal_returnsYes() {
        assertNoThrow {
            let call = Expression.call("Neq", [falseBool, trueBool])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
    }
}
