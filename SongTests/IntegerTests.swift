import XCTest
import Song

class IntegerTests: XCTestCase {
    
    func testConstructor() {
        let integer = SongExpression.SongInteger(5)
        switch integer {
        case let .SongInteger(value):
            XCTAssertEqual(5, value)
        default:
            XCTFail("not an integer")
        }
    }
    
    func testDescription() {
        let integer = SongExpression.SongInteger(5)
        let result = "\(integer)"
        XCTAssertEqual("5", result)
    }

    func testEvaluate() {
        let integer = SongExpression.SongInteger(5)
        let result = integer.evaluate()
        XCTAssertEqual(integer, result)
    }
}
