import XCTest

class IsUnitTests: XCTestCase {
    
    let isUnitValue = Expression.IsUnit(Expression.UnitValue)
    let isNotUnitValue = Expression.IsUnit(Expression.IntegerValue(1))
    
    func testConstructor() {
        switch isUnitValue {
        case .IsUnit:
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
        XCTAssertEqual(Expression.BooleanValue(true), result)
    }

    func testEvaluateIsNotUnitValue() {
        let result = isNotUnitValue.evaluate()
        XCTAssertEqual(Expression.BooleanValue(false), result)
    }
    
    func testEvaluateIsUnitReferencingContext() {
        let x = Expression.Variable("x")
        let unit = Expression.IsUnit(x)
        let result = unit.evaluate(context: ["x": Expression.UnitValue])
        XCTAssertEqual(Expression.BooleanValue(true), result)
    }
}
