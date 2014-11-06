import XCTest
import Song

class ErrorTests: XCTestCase {
    
    let error = Expression.Error("problem")

    func testDescription() {
        let result = "\(error)"
        XCTAssertEqual("<problem>", result)
    }
    
    func testEvaluate() {
        let result = error.evaluate()
        XCTAssertEqual(Expression.Error("problem"), result)
    }
}
