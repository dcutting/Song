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
}
