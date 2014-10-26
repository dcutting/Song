import XCTest
import Song

class IsUnitTests: XCTestCase {
    
    let isUnit = SongExpression.SongIsUnit(SongExpression.SongUnit)
    let isNotUnit = SongExpression.SongIsUnit(SongExpression.SongInteger(1))
    
    func testConstructor() {
        switch isUnit {
        case let .SongIsUnit:
            XCTAssertTrue(true)
        default:
            XCTFail("not an isUnit")
        }
    }
    
    func testDescriptionIsUnit() {
        let result = "\(isUnit)"
        XCTAssertEqual("isUnit(#)", result)
    }
    
    func testDescriptionIsNotUnit() {
        let result = "\(isNotUnit)"
        XCTAssertEqual("isUnit(1)", result)
    }
    
    func testEvaluateIsUnit() {
        let result = isUnit.evaluate()
        XCTAssertEqual(SongExpression.SongBoolean(true), result)
    }

    func testEvaluateIsNotUnit() {
        let result = isNotUnit.evaluate()
        XCTAssertEqual(SongExpression.SongBoolean(false), result)
    }
    
    func testEvaluateIsUnitReferencingContext() {
        let x = SongExpression.SongVariable("x")
        let unit = SongExpression.SongIsUnit(x)
        let result = unit.evaluate(["x": SongExpression.SongUnit])
        XCTAssertEqual(SongExpression.SongBoolean(true), result)
    }
}
