import XCTest
import Song

class IsUnitTests: XCTestCase {
    
    let isUnit = Expression.IsUnit(Expression.Unit)
    let isNotUnit = Expression.IsUnit(Expression.Integer(1))
    
    func testConstructor() {
        switch isUnit {
        case let .IsUnit:
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
        XCTAssertEqual(Expression.Boolean(true), result)
    }

    func testEvaluateIsNotUnit() {
        let result = isNotUnit.evaluate()
        XCTAssertEqual(Expression.Boolean(false), result)
    }
    
    func testEvaluateIsUnitReferencingContext() {
        let x = Expression.Variable("x")
        let unit = Expression.IsUnit(x)
        let result = unit.evaluate(["x": Expression.Unit])
        XCTAssertEqual(Expression.Boolean(true), result)
    }
}
