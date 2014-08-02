import XCTest
import Song

class UnitTests: XCTestCase {
    
    let unit = SongExpression.SongUnit
    
    func testConstructor() {
        switch unit {
        case let .SongUnit:
            XCTAssertTrue(true)
        default:
            XCTFail("not a unit")
        }
    }
    
    func testDescription() {
        let result = "\(unit)"
        XCTAssertEqual("#", result)
    }
    
    func testEvaluate() {
        let result = unit.evaluate()
        XCTAssertEqual(unit, result)
    }
}
