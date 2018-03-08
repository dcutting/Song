import XCTest
import Song

class CallTests: XCTestCase {
    
    func testDescription() {
        let function = Function(name: "echo", patterns: [Expression.name("x"), Expression.name("y")], when: Expression.bool(true), body: Expression.name("x"))
        assertNoThrow {
            let closure = try Expression.function(function).evaluate()
            let call = Expression.eval( closure, [Expression.int(99), Expression.int(100)])
            let result = "\(call)"
            XCTAssertEqual("[() [echo(x, y) = x]](99, 100)", result)
        }
    }

    func testFunctionDescription() {
        let left = Expression.int(5)
        let right = Expression.int(9)
        let foo = Expression.call("foo", [left, right])
        XCTAssertEqual("foo(5, 9)", "\(foo)")
    }

    func testEquatable_call_same_returnsTrue() {
        let left = Expression.call("foo", [.int(9)])
        let right = Expression.call("foo", [.int(9)])
        XCTAssertEqual(left, right)
    }

    func testEquatable_call_differentName_returnsFalse() {
        let left = Expression.call("foo", [.int(9)])
        let right = Expression.call("bar", [.int(9)])
        XCTAssertNotEqual(left, right)
    }

    func testEquatable_call_differentArguments_returnsFalse() {
        let left = Expression.call("foo", [.int(9)])
        let right = Expression.call("foo", [.string("hi")])
        XCTAssertNotEqual(left, right)
    }

    func testEquatable_callAnonymous_same_returnsTrue() {
        let left = Expression.eval(.int(9), [.int(5)])
        let right = Expression.eval(.int(9), [.int(5)])
        XCTAssertEqual(left, right)
    }

    func testEquatable_callAnonymous_differentClosure_returnsFalse() {
        let left = Expression.eval(.int(1), [.int(5)])
        let right = Expression.eval(.int(9), [.int(5)])
        XCTAssertNotEqual(left, right)
    }

    func testEquatable_callAnonymous_differentArguments_returnsFalse() {
        let left = Expression.eval(.int(9), [.int(5)])
        let right = Expression.eval(.int(9), [.int(1)])
        XCTAssertNotEqual(left, right)
    }

    func testEvaluateCallingNonClosure() {
        let call = Expression.eval(Expression.int(5), [])
        XCTAssertThrowsError(try call.evaluate())
    }

    func testEvaluateCallingInvalidClosure() {
        let closure = Expression.closure(nil, [.int(5)], Context())
        let call = Expression.eval(closure, [])
        XCTAssertThrowsError(try call.evaluate())
    }

    func testEvaluateCallingFunctionReferencedInContext() {
        assertNoThrow {
            let function = Expression.function(Function(name: "five", patterns: [], when: .bool(true), body: .int(5)))
            let closure = try function.evaluate()
            let call = Expression.eval(Expression.name("f"), [])
            let result = try call.evaluate(context: ["f": closure])
            XCTAssertEqual(Expression.int(5), result)
        }
    }
    
    func testEvaluateClosureWithoutParameters() {
        assertNoThrow {
            let function = Expression.function(Function(name: "five", patterns: [], when: .bool(true), body: Expression.int(5)))
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(5), result)
        }
    }
    
    func testEvaluateClosureReferencesDeclarationContext() {
        let function = Expression.function(Function(name: "getX", patterns: [], when: .bool(true), body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate(context: ["x": .int(7)])
            let call = Expression.eval(closure, [])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(7), result)
        }
    }
    
    func testEvaluateClosureCapturesCallingContext() {
        let function = Expression.function(Function(name: "getX", patterns: [], when: .bool(true), body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [])
            XCTAssertEqual(Expression.int(7), try call.evaluate(context: ["x": .int(7)]))
        }
    }
    
    func testEvaluateClosureWithParameter() {
        let function = Expression.function(Function(name: "echo", patterns: [.name("x")], when: .bool(true), body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [Expression.int(7)])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(7), result)
        }
    }
    
    func testEvaluateClosureWithArgumentReferencingCallingContext() {
        let function = Expression.function(Function(name: "echo", patterns: [.name("x")], when: .bool(true), body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [Expression.name("y")])
            let result = try call.evaluate(context: ["y": .int(15)])
            XCTAssertEqual(Expression.int(15), result)
        }
    }
    
    func testEvaluateClosureWithoutEnoughArguments() {
        let function = Expression.function(Function(name: "echo", patterns: [.name("x"), .name("y")], when: .bool(true), body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [Expression.int(7)])
            XCTAssertThrowsError(try call.evaluate())
        }
    }
    
    func testEvaluateClosureWithTooManyArguments() {
        let function = Expression.function(Function(name: "echo", patterns: [.name("x")], when: .bool(true), body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [Expression.int(7), Expression.int(8)])
            XCTAssertThrowsError(try call.evaluate())
        }
    }

    func test_evaluateClosure_nonBooleanWhenClause_throws() {
        let function = Expression.function(Function(name: "echo", patterns: [], when: .int(1), body: .bool(true)))
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": closure]
            let call = Expression.call("echo", [])
            XCTAssertThrowsError(try call.evaluate(context: context))
        }
    }

    func test_evaluateClosure_falseWhenClause_throws() {
        let function = Expression.function(Function(name: "echo", patterns: [], when: .bool(false), body: .bool(true)))
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": closure]
            let call = Expression.call("echo", [])
            XCTAssertThrowsError(try call.evaluate(context: context))
        }
    }

    func test_evaluateClosure_trueWhenClause_succeeds() {
        let function = Expression.function(Function(name: "echo", patterns: [], when: .bool(true), body: .int(9)))
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": closure]
            let call = Expression.call("echo", [])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.int(9), actual)
        }
    }

    func testEvaluateLambda() {
        let function = Function(name: nil, patterns: [.name("x")], when: .bool(true), body: .name("x"))
        assertNoThrow {
            let lambda = try Expression.function(function).evaluate()
            let call = Expression.eval(lambda, [Expression.int(7)])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(7), result)
        }
    }

    func test_call_missingSymbol() {
        let call = Expression.call("noSuchFunction", [])
        XCTAssertThrowsError(try call.evaluate())
    }
}
