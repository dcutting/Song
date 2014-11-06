import XCTest
import Song

class UnitTests: XCTestCase {
    
    let unit = Expression.Unit
    
    func testConstructor() {
        switch unit {
        case let .Unit:
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
