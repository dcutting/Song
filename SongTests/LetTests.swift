import XCTest
import Song

class LetTests: XCTestCase {
    
    let letExpression = Expression.Let(name: "company", binding: Expression.StringValue("Yellowbek"), body: Expression.Variable("company"))
    
    func testDescription() {
        let result = "\(letExpression)"
        XCTAssertEqual("let (company = 'Yellowbek') { company }", result)
    }
    
    func testEvaluate() {
        let result = letExpression.evaluate()
        XCTAssertEqual(Expression.StringValue("Yellowbek"), result)
    }
    
    func testEmbeddedLet() {
        
        let innerLetExpression = Expression.Let(name: "x", binding: Expression.Variable("y"), body: Expression.Variable("x"))

        let outerLetExpression = Expression.Let(name: "y", binding: Expression.IntegerValue(99), body: innerLetExpression)
        
        let result = outerLetExpression.evaluate()
        XCTAssertEqual(Expression.IntegerValue(99), result)
    }
    
    func testContextNotShared() {

        let context = ["company": Expression.IntegerValue(5)]
        
        letExpression.evaluate(context)
        
        let result = Expression.Variable("company").evaluate(context)
        XCTAssertEqual(Expression.IntegerValue(5), result)
    }
}
