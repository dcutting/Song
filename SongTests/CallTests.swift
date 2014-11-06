import XCTest
import Song

class CallTests: XCTestCase {
    
    func testDescription() {
        let closure = Expression.Function(name: "echo", parameters: ["x", "y"], body: Expression.Variable("x")).evaluate()
        let call = Expression.Call(closure: closure, arguments: [Expression.Integer(99), Expression.Integer(100)])
        let result = "\(call)"
        XCTAssertEqual("[() def echo(x, y) { x }](99, 100)", result)
    }

    func testEvaluateCallingNonClosure() {
        let call = Expression.Call(closure: Expression.Integer(5), arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.Error("5 is not a closure"), result)
    }

    func testEvaluateCallingInvalidClosure() {
        let closure = Expression.Closure(function: Expression.Integer(5), context: SongContext())
        let call = Expression.Call(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.Error("closure does not wrap function"), result)
    }
    
    func testEvaluateCallingFunctionReferencedInContext() {
        let function = Expression.Function(name: "five", parameters: [], body: Expression.Integer(5))
        let closure = function.evaluate()
        let call = Expression.Call(closure: Expression.Variable("f"), arguments: [])
        let result = call.evaluate(["f": closure])
        XCTAssertEqual(Expression.Integer(5), result)
    }
    
    func testEvaluateClosureWithoutParameters() {
        let function = Expression.Function(name: "five", parameters: [], body: Expression.Integer(5))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.Integer(5), result)
    }
    
    func testEvaluateClosureReferencesDeclarationContext() {
        let function = Expression.Function(name: "getX", parameters: [], body: Expression.Variable("x"))
        let closure = function.evaluate(["x": Expression.Integer(7)])
        let call = Expression.Call(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.Integer(7), result)
    }
    
    func testEvaluateClosureIgnoresCallingContext() {
        let function = Expression.Function(name: "getX", parameters: [], body: Expression.Variable("x"))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [])
        let result = call.evaluate(["x": Expression.Integer(7)])
        XCTAssertEqual(Expression.Error("cannot evaluate x"), result)
    }
    
    func testEvaluateClosureWithParameter() {
        let function = Expression.Function(name: "echo", parameters: ["x"], body: Expression.Variable("x"))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [Expression.Integer(7)])
        let result = call.evaluate()
        XCTAssertEqual(Expression.Integer(7), result)
    }
    
    func testEvaluateClosureWithArgumentReferencingCallingContext() {
        let function = Expression.Function(name: "echo", parameters: ["x"], body: Expression.Variable("x"))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [Expression.Variable("y")])
        let result = call.evaluate(["y": Expression.Integer(15)])
        XCTAssertEqual(Expression.Integer(15), result)
    }
    
    func testEvaluateClosureWithoutEnoughArguments() {
        let function = Expression.Function(name: "echo", parameters: ["x", "y"], body: Expression.Variable("x"))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [Expression.Integer(7)])
        let result = call.evaluate()
        XCTAssertEqual(Expression.Error("not enough arguments"), result)
    }
    
    func testEvaluateClosureWithTooManyArguments() {
        let function = Expression.Function(name: "echo", parameters: ["x"], body: Expression.Variable("x"))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [Expression.Integer(7), Expression.Integer(8)])
        let result = call.evaluate()
        XCTAssertEqual(Expression.Error("too many arguments"), result)
    }
    
    func testEvaluateClosureExtendsContextWithRecursiveReference() {
        let listVar = Expression.Variable("list")
        let isUnit = Expression.IsUnit(listVar)
        let zero = Expression.Integer(0)
        let one = Expression.Integer(1)
        let second = Expression.Second(listVar)
        let recursiveCall = Expression.Call(closure: Expression.Variable("length"), arguments: [second])
        let otherwise = Expression.Plus(one, recursiveCall)
        let lengthBody = Expression.Conditional(condition: isUnit, then: zero, otherwise: otherwise)
        let lengthFunc = Expression.Function(name: "length", parameters: ["list"], body: lengthBody)
        let lengthClosure = lengthFunc.evaluate()
        let list = Expression.Pair(Expression.Integer(5), Expression.Unit)
        let lengthCall = Expression.Call(closure: lengthClosure, arguments: [list])
        let result = lengthCall.evaluate()
        
        XCTAssertEqual(Expression.Integer(1), result)
    }
}
