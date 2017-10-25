import XCTest
import Song

class LetTests: XCTestCase {
    
    let letExpression = Expression.let(name: "company", binding: Expression.stringValue("Yellowbek"), body: Expression.variable("company"))
    
    func testDescription() {
        let result = "\(letExpression)"
        XCTAssertEqual("let (company = 'Yellowbek') { company }", result)
    }
    
    func testEvaluate() {
        let result = letExpression.evaluate()
        XCTAssertEqual(Expression.stringValue("Yellowbek"), result)
    }
    
    func testEmbeddedLet() {
        
        let innerLetExpression = Expression.let(name: "x", binding: Expression.variable("y"), body: Expression.variable("x"))

        let outerLetExpression = Expression.let(name: "y", binding: Expression.integerValue(99), body: innerLetExpression)
        
        let result = outerLetExpression.evaluate()
        XCTAssertEqual(Expression.integerValue(99), result)
    }
    
    func testContextNotShared() {

        let context = ["company": Expression.integerValue(5)]
        
        _ = letExpression.evaluate(context: context)
        
        let result = Expression.variable("company").evaluate(context: context)
        XCTAssertEqual(Expression.integerValue(5), result)
    }
}
