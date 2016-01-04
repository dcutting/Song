import XCTest
import Song

class UnitValueTests: XCTestCase {
    
    let unit = Expression.UnitValue
    
    func testConstructor() {
        switch unit {
        case .UnitValue:
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
