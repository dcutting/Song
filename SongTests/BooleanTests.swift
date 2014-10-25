import XCTest
import Song

class BooleanTests: XCTestCase {
    
    let trueBoolean = SongExpression.SongBoolean(true)
    let falseBoolean = SongExpression.SongBoolean(false)
    
    func testConstructor() {
        switch trueBoolean {
        case let .SongBoolean:
            XCTAssertTrue(true)
        default:
            XCTFail("not a boolean")
        }
    }
    
    func testDescriptionTrue() {
        let result = "\(trueBoolean)"
        XCTAssertEqual("yes", result)
    }
    
    func testDescriptionFalse() {
        let result = "\(falseBoolean)"
        XCTAssertEqual("no", result)
    }
    
    func testEvaluateTrue() {
        let result = trueBoolean.evaluate()
        XCTAssertEqual(trueBoolean, result)
    }
    
    func testEvaluateFalse() {
        let result = falseBoolean.evaluate()
        XCTAssertEqual(falseBoolean, result)
    }
}
