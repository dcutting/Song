import XCTest
import Song

class UnitValueTests: XCTestCase {
    
    let unit = Expression.unitValue
    
    func testConstructor() {
        switch unit {
        case .unitValue:
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
        assertNoThrow {
            let result = try unit.evaluate()
            XCTAssertEqual(unit, result)
        }
    }
}
