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
        XCTAssertEqual(SongExpression.SongError("5 is not a closure"), result)
    }

    func testEvaluateCallingInvalidClosure() {
        let closure = SongExpression.SongClosure(function: SongExpression.SongInteger(5), context: SongContext())
        let call = SongExpression.SongCall(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(SongExpression.SongError("closure does not wrap function"), result)
    }
    
    func testEvaluateCallingFunctionReferencedInContext() {
        let function = SongExpression.SongFunction(name: "five", parameters: [], body: SongExpression.SongInteger(5))
        let closure = function.evaluate()
        let call = SongExpression.SongCall(closure: SongExpression.SongVariable("f"), arguments: [])
        let result = call.evaluate(["f": closure])
        XCTAssertEqual(SongExpression.SongInteger(5), result)
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
        let closure = function.evaluate(["x": SongExpression.SongInteger(7)])
        let call = SongExpression.SongCall(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(SongExpression.SongInteger(7), result)
    }
    
    func testEvaluateClosureIgnoresCallingContext() {
        let function = SongExpression.SongFunction(name: "getX", parameters: [], body: SongExpression.SongVariable("x"))
        let closure = function.evaluate()
        let call = SongExpression.SongCall(closure: closure, arguments: [])
        let result = call.evaluate(["x": SongExpression.SongInteger(7)])
        XCTAssertEqual(SongExpression.SongError("cannot evaluate x"), result)
    }
    
    func testEvaluateClosureWithParameter() {
        let function = SongExpression.SongFunction(name: "echo", parameters: ["x"], body: SongExpression.SongVariable("x"))
        let closure = function.evaluate()
        let call = SongExpression.SongCall(closure: closure, arguments: [SongExpression.SongInteger(7)])
        let result = call.evaluate()
        XCTAssertEqual(SongExpression.SongInteger(7), result)
    }
    
    func testEvaluateClosureWithArgumentReferencingCallingContext() {
        let function = SongExpression.SongFunction(name: "echo", parameters: ["x"], body: SongExpression.SongVariable("x"))
        let closure = function.evaluate()
        let call = SongExpression.SongCall(closure: closure, arguments: [SongExpression.SongVariable("y")])
        let result = call.evaluate(["y": SongExpression.SongInteger(15)])
        XCTAssertEqual(SongExpression.SongInteger(15), result)
    }
    
    func testEvaluateClosureWithoutEnoughArguments() {
        let function = SongExpression.SongFunction(name: "echo", parameters: ["x", "y"], body: SongExpression.SongVariable("x"))
        let closure = function.evaluate()
        let call = SongExpression.SongCall(closure: closure, arguments: [SongExpression.SongInteger(7)])
        let result = call.evaluate()
        XCTAssertEqual(SongExpression.SongError("not enough arguments"), result)
    }
    
    func testEvaluateClosureWithTooManyArguments() {
        let function = SongExpression.SongFunction(name: "echo", parameters: ["x"], body: SongExpression.SongVariable("x"))
        let closure = function.evaluate()
        let call = SongExpression.SongCall(closure: closure, arguments: [SongExpression.SongInteger(7), SongExpression.SongInteger(8)])
        let result = call.evaluate()
        XCTAssertEqual(SongExpression.SongError("too many arguments"), result)
    }
}
