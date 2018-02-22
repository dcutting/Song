import XCTest
import Song

class VariableTests: XCTestCase {
    
    let variable = Expression.variable("n")
    
    func testDescription() {
        let result = "\(variable)"
        XCTAssertEqual("n", result)
    }

    func testEvaluateBoundVariable() {
        let context: Context = ["n": [.integerValue(5)]]
        assertNoThrow {
            let result = try variable.evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(5), result)
        }
    }
    
    func testEvaluateUnboundVariable() {
        XCTAssertThrowsError(try variable.evaluate())
    }
}
