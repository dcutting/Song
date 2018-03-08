import XCTest
import Song

class BoolTests: XCTestCase {
    
    let trueBooleanValue = Expression.bool(true)
    let falseBooleanValue = Expression.bool(false)
    
    func testDescriptionTrue() {
        let result = "\(trueBooleanValue)"
        XCTAssertEqual("Yes", result)
    }
    
    func testDescriptionFalse() {
        let result = "\(falseBooleanValue)"
        XCTAssertEqual("No", result)
    }
    
    func testEvaluateTrue() {
        assertNoThrow {
            let result = try trueBooleanValue.evaluate()
            XCTAssertEqual(trueBooleanValue, result)
        }
    }
    
    func testEvaluateFalse() {
        assertNoThrow {
            let result = try falseBooleanValue.evaluate()
            XCTAssertEqual(falseBooleanValue, result)
        }
    }

    func test_eq_equal_returnsYes() {
        assertNoThrow {
            let call = Expression.call("Eq", [trueBooleanValue, trueBooleanValue])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
    }

    func test_eq_unequal_returnsNo() {
        assertNoThrow {
            let call = Expression.call("Eq", [falseBooleanValue, trueBooleanValue])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
    }

    func test_notEq_equal_returnsNo() {
        assertNoThrow {
            let call = Expression.call("Neq", [trueBooleanValue, trueBooleanValue])
            XCTAssertEqual(Expression.bool(false), try call.evaluate())
        }
    }

    func test_notEq_unequal_returnsYes() {
        assertNoThrow {
            let call = Expression.call("Neq", [falseBooleanValue, trueBooleanValue])
            XCTAssertEqual(Expression.bool(true), try call.evaluate())
        }
    }
}
