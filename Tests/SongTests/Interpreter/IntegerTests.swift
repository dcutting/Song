import XCTest
import Song

class IntegerTests: XCTestCase {

    func testDescription() {
        let result = "\(Expression.int(5))"
        XCTAssertEqual("5", result)
    }

    func testEvaluate() {
        assertNoThrow {
            let number = Expression.int(5)
            let actual = try number.evaluate()
            XCTAssertEqual(number, actual)
        }
    }
}
