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
}
