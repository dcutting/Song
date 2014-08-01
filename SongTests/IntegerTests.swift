import XCTest
import Song

class IntegerTests: XCTestCase {

    let integer = SongExpression.SongInteger(5)

    func testConstructor() {
        switch integer {
        case let .SongInteger(value):
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
        let result = integer.evaluate()
        XCTAssertEqual(integer, result)
    }
}
