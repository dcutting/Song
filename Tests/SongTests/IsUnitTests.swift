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
        XCTAssertEqual("isUnit?([])", result)
    }
    
    func testDescriptionIsNotUnitValue() {
        let result = "\(isNotUnitValue)"
        XCTAssertEqual("isUnit?(1)", result)
    }
    
    func testEvaluateIsUnit() {
        assertNoThrow {
            let result = try isUnitValue.evaluate()
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }

    func testEvaluateIsNotUnitValue() {
        assertNoThrow {
            let result = try isNotUnitValue.evaluate()
            XCTAssertEqual(Expression.booleanValue(false), result)
        }
    }
    
    func testEvaluateIsUnitReferencingContext() {
        assertNoThrow {
            let x = Expression.variable("x")
            let unit = Expression.isUnit(x)
            let result = try unit.evaluate(context: ["x": [.unitValue]])
            XCTAssertEqual(Expression.booleanValue(true), result)
        }
    }
}
