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
    
    func testEvaluateClosureWithoutParameters() {
        let function = SongExpression.SongFunction(name: "five", parameters: [], body: SongExpression.SongInteger(5))
        let closure = function.evaluate()
        let call = SongExpression.SongCall(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(SongExpression.SongInteger(5), result)
    }
    
    func testEvaluateClosureReferencesDeclarationContext() {
        let function = SongExpression.SongFunction(name: "getX", parameters: [], body: SongExpression.SongVariable("x"))
        let closure = function.evaluate([ "x": SongExpression.SongInteger(7) ])
        let call = SongExpression.SongCall(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(SongExpression.SongInteger(7), result)
    }
    
    func testEvaluateClosureIgnoresCallingContext() {
        let function = SongExpression.SongFunction(name: "getX", parameters: [], body: SongExpression.SongVariable("x"))
        let closure = function.evaluate()
        let call = SongExpression.SongCall(closure: closure, arguments: [])
        let result = call.evaluate([ "x": SongExpression.SongInteger(7) ])
        XCTAssertEqual(SongExpression.SongError("cannot evaluate x"), result)
    }
}
