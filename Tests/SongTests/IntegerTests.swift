import XCTest
import Song

class IntegerTests: XCTestCase {

    let integer = Expression.integerValue(5)

    func testConstructor() {
        switch integer {
        case let .integerValue(value):
            XCTAssertEqual(5, value)
        default:
            XCTFail("not an integer")
        }
    }
    
    func testDescription() {
        let result = "\(integer)"
        XCTAssertEqual("5", result)
    }

    func testEvaluate() {
        assertNoThrow {
            let result = try integer.evaluate()
            XCTAssertEqual(integer, result)
        }
    }
}
