import XCTest
import Song

class CallTests: XCTestCase {
    
    func testDescription() {
        let closure = Expression.Function(name: "echo", parameters: ["x", "y"], body: Expression.Variable("x")).evaluate()
        let call = Expression.Call(closure: closure, arguments: [Expression.IntegerValue(99), Expression.IntegerValue(100)])
        let result = "\(call)"
        XCTAssertEqual("[() def echo(x, y) { x }](99, 100)", result)
    }

    func testEvaluateCallingNonClosure() {
        let call = Expression.Call(closure: Expression.IntegerValue(5), arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.Error("5 is not a closure"), result)
    }

    func testEvaluateCallingInvalidClosure() {
        let closure = Expression.Closure(function: Expression.IntegerValue(5), context: Context())
        let call = Expression.Call(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.Error("closure does not wrap function"), result)
    }
    
    func testEvaluateCallingFunctionReferencedInContext() {
        let function = Expression.Function(name: "five", parameters: [], body: Expression.IntegerValue(5))
        let closure = function.evaluate()
        let call = Expression.Call(closure: Expression.Variable("f"), arguments: [])
        let result = call.evaluate(["f": closure])
        XCTAssertEqual(Expression.IntegerValue(5), result)
    }
    
    func testEvaluateClosureWithoutParameters() {
        let function = Expression.Function(name: "five", parameters: [], body: Expression.IntegerValue(5))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.IntegerValue(5), result)
    }
    
    func testEvaluateClosureReferencesDeclarationContext() {
        let function = Expression.Function(name: "getX", parameters: [], body: Expression.Variable("x"))
        let closure = function.evaluate(["x": Expression.IntegerValue(7)])
        let call = Expression.Call(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.IntegerValue(7), result)
    }
    
    func testEvaluateClosureIgnoresCallingContext() {
        let function = Expression.Function(name: "getX", parameters: [], body: Expression.Variable("x"))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [])
        let result = call.evaluate(["x": Expression.IntegerValue(7)])
        XCTAssertEqual(Expression.Error("cannot evaluate x"), result)
    }
    
    func testEvaluateClosureWithParameter() {
        let function = Expression.Function(name: "echo", parameters: ["x"], body: Expression.Variable("x"))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [Expression.IntegerValue(7)])
        let result = call.evaluate()
        XCTAssertEqual(Expression.IntegerValue(7), result)
    }
    
    func testEvaluateClosureWithArgumentReferencingCallingContext() {
        let function = Expression.Function(name: "echo", parameters: ["x"], body: Expression.Variable("x"))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [Expression.Variable("y")])
        let result = call.evaluate(["y": Expression.IntegerValue(15)])
        XCTAssertEqual(Expression.IntegerValue(15), result)
    }
    
    func testEvaluateClosureWithoutEnoughArguments() {
        let function = Expression.Function(name: "echo", parameters: ["x", "y"], body: Expression.Variable("x"))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [Expression.IntegerValue(7)])
        let result = call.evaluate()
        XCTAssertEqual(Expression.Error("not enough arguments"), result)
    }
    
    func testEvaluateClosureWithTooManyArguments() {
        let function = Expression.Function(name: "echo", parameters: ["x"], body: Expression.Variable("x"))
        let closure = function.evaluate()
        let call = Expression.Call(closure: closure, arguments: [Expression.IntegerValue(7), Expression.IntegerValue(8)])
        let result = call.evaluate()
        XCTAssertEqual(Expression.Error("too many arguments"), result)
    }
    
    func testEvaluateClosureExtendsContextWithRecursiveReference() {
        let listVar = Expression.Variable("list")
        let isUnitValue = Expression.IsUnit(listVar)
        let zero = Expression.IntegerValue(0)
        let one = Expression.IntegerValue(1)
        let second = Expression.Second(listVar)
        let recursiveCall = Expression.Call(closure: Expression.Variable("length"), arguments: [second])
        let otherwise = Expression.Plus(one, recursiveCall)
        let lengthBody = Expression.Conditional(condition: isUnitValue, then: zero, otherwise: otherwise)
        let lengthFunc = Expression.Function(name: "length", parameters: ["list"], body: lengthBody)
        let lengthClosure = lengthFunc.evaluate()
        let list = Expression.Pair(Expression.IntegerValue(5), Expression.UnitValue)
        let lengthCall = Expression.Call(closure: lengthClosure, arguments: [list])
        let result = lengthCall.evaluate()
        
        XCTAssertEqual(Expression.IntegerValue(1), result)
    }
    
    func testEvaluateLambda() {
        let lambda = Expression.Function(name: nil, parameters: ["x"], body: Expression.Variable("x")).evaluate()
        let call = Expression.Call(closure: lambda, arguments: [Expression.IntegerValue(7)])
        let result = call.evaluate()
        XCTAssertEqual(Expression.IntegerValue(7), result)
    }
}
