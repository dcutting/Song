import XCTest
import Song

class ErrorTests: XCTestCase {
    
    let error = Expression.error("problem")

    func testDescription() {
        let result = "\(error)"
        XCTAssertEqual("<problem>", result)
    }
    
    func testEvaluate() {
        let result = error.evaluate()
        XCTAssertEqual(Expression.error("problem"), result)
    }
}
