import XCTest
import Song

class IfTests: XCTestCase {
    
    func testDescription() {
        let condition = Expression.booleanValue(true)
        let then = Expression.integerValue(5)
        let otherwise = Expression.integerValue(7)
        let ifExpr = Expression.conditional(condition: condition, then: then, otherwise: otherwise)
        let result = "\(ifExpr)"
        XCTAssertEqual("if yes then 5 else 7 end", result)
    }
    
    func testConditionNotBooleanValueExpression() {
        let condition = Expression.integerValue(10)
        let then = Expression.integerValue(5)
        let otherwise = Expression.integerValue(7)
        let ifExpr = Expression.conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate()
        XCTAssertEqual(Expression.error("boolean expression expected"), result)
    }
    
    func testEvaluatesCondition() {
        let condition = Expression.variable("x")
        let then = Expression.integerValue(5)
        let otherwise = Expression.integerValue(7)
        let ifExpr = Expression.conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate(context: ["x": Expression.booleanValue(true)])
        XCTAssertEqual(Expression.integerValue(5), result)
    }
    
    func testTrueBranch() {
        let condition = Expression.booleanValue(true)
        let then = Expression.variable("x")
        let otherwise = Expression.integerValue(7)
        let ifExpr = Expression.conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate(context: ["x": Expression.integerValue(5)])
        XCTAssertEqual(Expression.integerValue(5), result)
    }
    
    func testFalseBranch() {
        let condition = Expression.booleanValue(false)
        let then = Expression.integerValue(5)
        let otherwise = Expression.variable("y")
        let ifExpr = Expression.conditional(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate(context: ["y": Expression.integerValue(7)])
        XCTAssertEqual(Expression.integerValue(7), result)
    }
}
