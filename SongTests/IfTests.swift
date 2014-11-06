import XCTest
import Song

class IfTests: XCTestCase {
    
    func testDescription() {
        let condition = Expression.Boolean(true)
        let then = Expression.Integer(5)
        let otherwise = Expression.Integer(7)
        let ifExpr = Expression.Conditional(condition: condition, then: then, otherwise: otherwise)
        let result = "\(ifExpr)"
        XCTAssertEqual("if yes then 5 else 7 end", result)
    }
    
    func testConditionNotBooleanExpression() {
        let condition = Expression.Integer(10)
        let then = Expression.Integer(5)
        let otherwise = Expression.Integer(7)
        let ifExpr = Expression.Conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate()
        XCTAssertEqual(Expression.Error("boolean expression expected"), result)
    }
    
    func testEvaluatesCondition() {
        let condition = Expression.Variable("x")
        let then = Expression.Integer(5)
        let otherwise = Expression.Integer(7)
        let ifExpr = Expression.Conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate(["x": Expression.Boolean(true)])
        XCTAssertEqual(Expression.Integer(5), result)
    }
    
    func testTrueBranch() {
        let condition = Expression.Boolean(true)
        let then = Expression.Variable("x")
        let otherwise = Expression.Integer(7)
        let ifExpr = Expression.Conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate(["x": Expression.Integer(5)])
        XCTAssertEqual(Expression.Integer(5), result)
    }
    
    func testFalseBranch() {
        let condition = Expression.Boolean(false)
        let then = Expression.Integer(5)
        let otherwise = Expression.Variable("y")
        let ifExpr = Expression.Conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate(["y": Expression.Integer(7)])
        XCTAssertEqual(Expression.Integer(7), result)
    }
}
