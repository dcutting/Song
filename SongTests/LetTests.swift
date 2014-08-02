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
}
