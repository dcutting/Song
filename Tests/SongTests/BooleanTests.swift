import XCTest
import Song

class BooleanTests: XCTestCase {
    
    let trueBooleanValue = Expression.booleanValue(true)
    let falseBooleanValue = Expression.booleanValue(false)
    
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
            let call = Expression.call(name: "Eq", arguments: [trueBooleanValue, trueBooleanValue])
            XCTAssertEqual(Expression.booleanValue(true), try call.evaluate())
        }
    }

    func test_eq_unequal_returnsNo() {
        assertNoThrow {
            let call = Expression.call(name: "Eq", arguments: [falseBooleanValue, trueBooleanValue])
            XCTAssertEqual(Expression.booleanValue(false), try call.evaluate())
        }
    }

    func test_notEq_equal_returnsNo() {
        assertNoThrow {
            let call = Expression.call(name: "Neq", arguments: [trueBooleanValue, trueBooleanValue])
            XCTAssertEqual(Expression.booleanValue(false), try call.evaluate())
        }
    }

    func test_notEq_unequal_returnsYes() {
        assertNoThrow {
            let call = Expression.call(name: "Neq", arguments: [falseBooleanValue, trueBooleanValue])
            XCTAssertEqual(Expression.booleanValue(true), try call.evaluate())
        }
    }
}
