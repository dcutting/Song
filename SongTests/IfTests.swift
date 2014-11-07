import XCTest
import Song

class IfTests: XCTestCase {
    
    func testDescription() {
        let condition = Expression.BooleanValue(true)
        let then = Expression.IntegerValue(5)
        let otherwise = Expression.IntegerValue(7)
        let ifExpr = Expression.Conditional(condition: condition, then: then, otherwise: otherwise)
        let result = "\(ifExpr)"
        XCTAssertEqual("if yes then 5 else 7 end", result)
    }
    
    func testConditionNotBooleanValueExpression() {
        let condition = Expression.IntegerValue(10)
        let then = Expression.IntegerValue(5)
        let otherwise = Expression.IntegerValue(7)
        let ifExpr = Expression.Conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate()
        XCTAssertEqual(Expression.Error("boolean expression expected"), result)
    }
    
    func testEvaluatesCondition() {
        let condition = Expression.Variable("x")
        let then = Expression.IntegerValue(5)
        let otherwise = Expression.IntegerValue(7)
        let ifExpr = Expression.Conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate(["x": Expression.BooleanValue(true)])
        XCTAssertEqual(Expression.IntegerValue(5), result)
    }
    
    func testTrueBranch() {
        let condition = Expression.BooleanValue(true)
        let then = Expression.Variable("x")
        let otherwise = Expression.IntegerValue(7)
        let ifExpr = Expression.Conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate(["x": Expression.IntegerValue(5)])
        XCTAssertEqual(Expression.IntegerValue(5), result)
    }
    
    func testFalseBranch() {
        let condition = Expression.BooleanValue(false)
        let then = Expression.IntegerValue(5)
        let otherwise = Expression.Variable("y")
        let ifExpr = Expression.Conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate(["y": Expression.IntegerValue(7)])
        XCTAssertEqual(Expression.IntegerValue(7), result)
    }
}
