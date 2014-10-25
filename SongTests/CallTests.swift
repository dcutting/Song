import XCTest
import Song

class CallTests: XCTestCase {
    
    func testDescription() {
        let closure = SongExpression.SongFunction(name: "echo", parameters: ["x", "y"], body: SongExpression.SongVariable("x")).evaluate()
        let call = SongExpression.SongCall(closure: closure, arguments: [SongExpression.SongInteger(99), SongExpression.SongInteger(100)])
        let result = "\(call)"
        XCTAssertEqual("[() def echo(x, y) { x }](99, 100)", result)
    }

    func testEvaluateCallingNonClosure() {
        let call = SongExpression.SongCall(closure: SongExpression.SongInteger(5), arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(SongExpression.SongError("can only call closure"), result)
    }

    func testEvaluateCallingInvalidClosure() {
        let closure = SongExpression.SongClosure(function: SongExpression.SongInteger(5), context: SongContext())
        let call = SongExpression.SongCall(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(SongExpression.SongError("closure does not wrap function"), result)
    }
}
