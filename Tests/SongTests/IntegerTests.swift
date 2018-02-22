import XCTest
import Song

class IntegerTests: XCTestCase {

    func testDescription() {
        let result = "\(Expression.integerValue(5))"
        XCTAssertEqual("5", result)
    }

    func testEvaluate() {
        assertNoThrow {
            let number = Expression.integerValue(5)
            let actual = try number.evaluate()
            XCTAssertEqual(number, actual)
        }
    }
}
