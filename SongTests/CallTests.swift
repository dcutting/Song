import XCTest
import Song

class CallTests: XCTestCase {
    
    let closure = SongExpression.SongFunction(name: "echo", parameters: ["x", "y"], body: SongExpression.SongVariable("x")).evaluate()
    
    func testDescription() {
        let call = SongExpression.SongCall(closure: closure, arguments: [SongExpression.SongInteger(99), SongExpression.SongInteger(100)])
        let result = "\(call)"
        XCTAssertEqual("[() def echo(x, y) { x }](99, 100)", result)
    }
}
