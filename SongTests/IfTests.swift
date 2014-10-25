import XCTest
import Song

class IfTests: XCTestCase {
    
    func testDescription() {
        let condition = SongExpression.SongBoolean(true)
        let then = SongExpression.SongInteger(5)
        let otherwise = SongExpression.SongInteger(7)
        let ifExpr = SongExpression.SongIf(condition: condition, then: then, otherwise: otherwise)
        let result = "\(ifExpr)"
        XCTAssertEqual("if yes then 5 else 7 end", result)
    }
    
    func testConditionNotBooleanExpression() {
        let condition = SongExpression.SongInteger(10)
        let then = SongExpression.SongInteger(5)
        let otherwise = SongExpression.SongInteger(7)
        let ifExpr = SongExpression.SongIf(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate()
        XCTAssertEqual(SongExpression.SongError("boolean expression expected"), result)
    }
    
    func testEvaluatesCondition() {
        let condition = SongExpression.SongVariable("x")
        let then = SongExpression.SongInteger(5)
        let otherwise = SongExpression.SongInteger(7)
        let ifExpr = SongExpression.SongIf(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate([ "x": SongExpression.SongBoolean(true) ])
        XCTAssertEqual(SongExpression.SongInteger(5), result)
    }
    
    func testTrueBranch() {
        let condition = SongExpression.SongBoolean(true)
        let then = SongExpression.SongVariable("x")
        let otherwise = SongExpression.SongInteger(7)
        let ifExpr = SongExpression.SongIf(condition: condition, then: then, otherwise: otherwise)
        let result = ifExpr.evaluate([ "x": SongExpression.SongInteger(5) ])
        XCTAssertEqual(SongExpression.SongInteger(5), result)
    }
}
