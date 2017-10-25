import XCTest
import Song

class IsUnitTests: XCTestCase {
    
    let isUnitValue = Expression.isUnit(Expression.unitValue)
    let isNotUnitValue = Expression.isUnit(Expression.integerValue(1))
    
    func testConstructor() {
        switch isUnitValue {
        case .isUnit:
            XCTAssertTrue(true)
        default:
            XCTFail("not an isUnitValue")
        }
    }
    
    func testDescriptionIsUnit() {
        let result = "\(isUnitValue)"
        XCTAssertEqual("isUnitValue(#)", result)
    }
    
    func testDescriptionIsNotUnitValue() {
        let result = "\(isNotUnitValue)"
        XCTAssertEqual("isUnitValue(1)", result)
    }
    
    func testEvaluateIsUnit() {
        let result = isUnitValue.evaluate()
        XCTAssertEqual(Expression.booleanValue(true), result)
    }

    func testEvaluateIsNotUnitValue() {
        let result = isNotUnitValue.evaluate()
        XCTAssertEqual(Expression.booleanValue(false), result)
    }
    
    func testEvaluateIsUnitReferencingContext() {
        let x = Expression.variable("x")
        let unit = Expression.isUnit(x)
        let result = unit.evaluate(context: ["x": Expression.unitValue])
        XCTAssertEqual(Expression.booleanValue(true), result)
    }
}
