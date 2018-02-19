import XCTest
import Song

class FloatTests: XCTestCase {

    func testDescription() {
        let float = Expression.floatValue(5.3)
        let actual = "\(float)"
        XCTAssertEqual("5.3", actual)
    }

    func testEvaluate() {
        assertNoThrow {
            let float = Expression.floatValue(5.3)
            let actual = try float.evaluate()
            XCTAssertEqual(float, actual)
        }
    }
}
