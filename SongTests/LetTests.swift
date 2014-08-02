import XCTest
import Song

class LetTests: XCTestCase {
    
    let letExpression = SongExpression.SongLet(name: "company", binding: SongExpression.SongString("Yellowbek"), body: SongExpression.SongVariable("company"))
    
    func testDescription() {
        let result = "\(letExpression)"
        XCTAssertEqual("let (company = 'Yellowbek') { company }", result)
    }
    
    func testEvaluate() {
        let result = letExpression.evaluate()
        XCTAssertEqual(SongExpression.SongString("Yellowbek"), result)
    }
    
    func testEmbeddedLet() {
        
        let innerLetExpression = SongExpression.SongLet(name: "x", binding: SongExpression.SongVariable("y"), body: SongExpression.SongVariable("x"))

        let outerLetExpression = SongExpression.SongLet(name: "y", binding: SongExpression.SongInteger(99), body: innerLetExpression)
        
        let result = outerLetExpression.evaluate()
        XCTAssertEqual(SongExpression.SongInteger(99), result)
    }
    
    func testContextNotShared() {

        let context = ["company": SongExpression.SongInteger(5)]
        
        letExpression.evaluate(context)
        
        let result = SongExpression.SongVariable("company").evaluate(context)
        XCTAssertEqual(SongExpression.SongInteger(5), result)
    }
}
