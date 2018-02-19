import XCTest
import Song

class LetTests: XCTestCase {
    
    let letExpression = Expression.let(name: "company", binding: .stringValue("Yellowbek"), body: .variable("company"))
    
    func testDescription() {
        let result = "\(letExpression)"
        XCTAssertEqual("let (company = \"Yellowbek\") { company }", result)
    }
    
    func testEvaluate() {
        assertNoThrow {
            let result = try letExpression.evaluate()
            XCTAssertEqual(Expression.stringValue("Yellowbek"), result)
        }
    }
    
    func testEmbeddedLet() {
        
        let innerLetExpression = Expression.let(name: "x", binding: .variable("y"), body: .variable("x"))

        let outerLetExpression = Expression.let(name: "y", binding: .integerValue(99), body: innerLetExpression)
        
        assertNoThrow {
            let result = try outerLetExpression.evaluate()
            XCTAssertEqual(Expression.integerValue(99), result)
        }
    }
    
    func testContextNotShared() {

        let context: Context = ["company": .integerValue(5)]

        assertNoThrow {
            _ = try letExpression.evaluate(context: context)
            let result = try Expression.variable("company").evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(5), result)
        }
    }
}
