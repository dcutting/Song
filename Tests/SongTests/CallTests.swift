import XCTest
import Song

class CallTests: XCTestCase {
    
    func testDescription() {
        let closure = Expression.function(name: "echo", parameters: ["x", "y"], body: Expression.variable("x")).evaluate()
        let call = Expression.call(closure: closure, arguments: [Expression.integerValue(99), Expression.integerValue(100)])
        let result = "\(call)"
        XCTAssertEqual("[() def echo(x, y) { x }](99, 100)", result)
    }

    func testEvaluateCallingNonClosure() {
        let call = Expression.call(closure: Expression.integerValue(5), arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.error("5 is not a closure"), result)
    }

    func testEvaluateCallingInvalidClosure() {
        let closure = Expression.closure(function: Expression.integerValue(5), context: Context())
        let call = Expression.call(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.error("closure does not wrap function"), result)
    }
    
    func testEvaluateCallingFunctionReferencedInContext() {
        let function = Expression.function(name: "five", parameters: [], body: Expression.integerValue(5))
        let closure = function.evaluate()
        let call = Expression.call(closure: Expression.variable("f"), arguments: [])
        let result = call.evaluate(context: ["f": closure])
        XCTAssertEqual(Expression.integerValue(5), result)
    }
    
    func testEvaluateClosureWithoutParameters() {
        let function = Expression.function(name: "five", parameters: [], body: Expression.integerValue(5))
        let closure = function.evaluate()
        let call = Expression.call(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.integerValue(5), result)
    }
    
    func testEvaluateClosureReferencesDeclarationContext() {
        let function = Expression.function(name: "getX", parameters: [], body: Expression.variable("x"))
        let closure = function.evaluate(context: ["x": Expression.integerValue(7)])
        let call = Expression.call(closure: closure, arguments: [])
        let result = call.evaluate()
        XCTAssertEqual(Expression.integerValue(7), result)
    }
    
    func testEvaluateClosureIgnoresCallingContext() {
        let function = Expression.function(name: "getX", parameters: [], body: Expression.variable("x"))
        let closure = function.evaluate()
        let call = Expression.call(closure: closure, arguments: [])
        let result = call.evaluate(context: ["x": Expression.integerValue(7)])
        XCTAssertEqual(Expression.error("cannot evaluate x"), result)
    }
    
    func testEvaluateClosureWithParameter() {
        let function = Expression.function(name: "echo", parameters: ["x"], body: Expression.variable("x"))
        let closure = function.evaluate()
        let call = Expression.call(closure: closure, arguments: [Expression.integerValue(7)])
        let result = call.evaluate()
        XCTAssertEqual(Expression.integerValue(7), result)
    }
    
    func testEvaluateClosureWithArgumentReferencingCallingContext() {
        let function = Expression.function(name: "echo", parameters: ["x"], body: Expression.variable("x"))
        let closure = function.evaluate()
        let call = Expression.call(closure: closure, arguments: [Expression.variable("y")])
        let result = call.evaluate(context: ["y": Expression.integerValue(15)])
        XCTAssertEqual(Expression.integerValue(15), result)
    }
    
    func testEvaluateClosureWithoutEnoughArguments() {
        let function = Expression.function(name: "echo", parameters: ["x", "y"], body: Expression.variable("x"))
        let closure = function.evaluate()
        let call = Expression.call(closure: closure, arguments: [Expression.integerValue(7)])
        let result = call.evaluate()
        XCTAssertEqual(Expression.error("not enough arguments"), result)
    }
    
    func testEvaluateClosureWithTooManyArguments() {
        let function = Expression.function(name: "echo", parameters: ["x"], body: Expression.variable("x"))
        let closure = function.evaluate()
        let call = Expression.call(closure: closure, arguments: [Expression.integerValue(7), Expression.integerValue(8)])
        let result = call.evaluate()
        XCTAssertEqual(Expression.error("too many arguments"), result)
    }
    
    func testEvaluateClosureExtendsContextWithRecursiveReference() {
        let listVar = Expression.variable("list")
        let isUnitValue = Expression.isUnit(listVar)
        let zero = Expression.integerValue(0)
        let one = Expression.integerValue(1)
        let second = Expression.second(listVar)
        let recursiveCall = Expression.call(closure: Expression.variable("length"), arguments: [second])
        let otherwise = Expression.plus(one, recursiveCall)
        let lengthBody = Expression.conditional(condition: isUnitValue, then: zero, otherwise: otherwise)
        let lengthFunc = Expression.function(name: "length", parameters: ["list"], body: lengthBody)
        let lengthClosure = lengthFunc.evaluate()
        let list = Expression.pair(Expression.integerValue(5), Expression.unitValue)
        let lengthCall = Expression.call(closure: lengthClosure, arguments: [list])
        let result = lengthCall.evaluate()
        
        XCTAssertEqual(Expression.integerValue(1), result)
    }
    
    func testEvaluateLambda() {
        let lambda = Expression.function(name: nil, parameters: ["x"], body: Expression.variable("x")).evaluate()
        let call = Expression.call(closure: lambda, arguments: [Expression.integerValue(7)])
        let result = call.evaluate()
        XCTAssertEqual(Expression.integerValue(7), result)
    }
}
