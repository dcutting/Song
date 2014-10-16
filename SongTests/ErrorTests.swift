import XCTest
import Song

class ErrorTests: XCTestCase {
    
    let error = SongExpression.SongError("problem")

    func testDescription() {
        let result = "\(error)"
        XCTAssertEqual("<problem>", result)
    }
    
    func testEvaluate() {
        let result = error.evaluate()
        XCTAssertEqual(SongExpression.SongError("problem"), result)
    }
}
