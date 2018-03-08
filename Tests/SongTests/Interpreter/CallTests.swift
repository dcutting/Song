import XCTest
import Song

class CallTests: XCTestCase {
    
    func testDescription() {
        let subfunction = Subfunction(name: "echo", patterns: [Expression.variable("x"), Expression.variable("y")], when: Expression.bool(true), body: Expression.variable("x"))
        assertNoThrow {
            let closure = try Expression.subfunction(subfunction).evaluate()
            let call = Expression.callAnon( closure, [Expression.int(99), Expression.int(100)])
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
        let left = Expression.callAnon(.int(9), [.int(5)])
        let right = Expression.callAnon(.int(9), [.int(5)])
        XCTAssertEqual(left, right)
    }

    func testEquatable_callAnonymous_differentClosure_returnsFalse() {
        let left = Expression.callAnon(.int(1), [.int(5)])
        let right = Expression.callAnon(.int(9), [.int(5)])
        XCTAssertNotEqual(left, right)
    }

    func testEquatable_callAnonymous_differentArguments_returnsFalse() {
        let left = Expression.callAnon(.int(9), [.int(5)])
        let right = Expression.callAnon(.int(9), [.int(1)])
        XCTAssertNotEqual(left, right)
    }

    func testEvaluateCallingNonClosure() {
        let call = Expression.callAnon(Expression.int(5), [])
        XCTAssertThrowsError(try call.evaluate())
    }

    func testEvaluateCallingInvalidClosure() {
        let closure = Expression.closure(nil, [.int(5)], Context())
        let call = Expression.callAnon(closure, [])
        XCTAssertThrowsError(try call.evaluate())
    }

    func testEvaluateCallingFunctionReferencedInContext() {
        assertNoThrow {
            let subfunction = Subfunction(name: "five", patterns: [], when: .bool(true), body: .int(5))
            let function = Expression.subfunction(subfunction)
            let closure = try function.evaluate()
            let call = Expression.callAnon(Expression.variable("f"), [])
            let result = try call.evaluate(context: ["f": closure])
            XCTAssertEqual(Expression.int(5), result)
        }
    }
    
    func testEvaluateClosureWithoutParameters() {
        assertNoThrow {
            let subfunction = Subfunction(name: "five", patterns: [], when: .bool(true), body: Expression.int(5))
            let function = Expression.subfunction(subfunction)
            let closure = try function.evaluate()
            let call = Expression.callAnon(closure, [])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(5), result)
        }
    }
    
    func testEvaluateClosureReferencesDeclarationContext() {
        let subfunction = Subfunction(name: "getX", patterns: [], when: .bool(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate(context: ["x": .int(7)])
            let call = Expression.callAnon(closure, [])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(7), result)
        }
    }
    
    func testEvaluateClosureCapturesCallingContext() {
        let subfunction = Subfunction(name: "getX", patterns: [], when: .bool(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.callAnon(closure, [])
            XCTAssertEqual(Expression.int(7), try call.evaluate(context: ["x": .int(7)]))
        }
    }
    
    func testEvaluateClosureWithParameter() {
        let subfunction = Subfunction(name: "echo", patterns: [.variable("x")], when: .bool(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.callAnon(closure, [Expression.int(7)])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(7), result)
        }
    }
    
    func testEvaluateClosureWithArgumentReferencingCallingContext() {
        let subfunction = Subfunction(name: "echo", patterns: [.variable("x")], when: .bool(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.callAnon(closure, [Expression.variable("y")])
            let result = try call.evaluate(context: ["y": .int(15)])
            XCTAssertEqual(Expression.int(15), result)
        }
    }
    
    func testEvaluateClosureWithoutEnoughArguments() {
        let subfunction = Subfunction(name: "echo", patterns: [.variable("x"), .variable("y")], when: .bool(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.callAnon(closure, [Expression.int(7)])
            XCTAssertThrowsError(try call.evaluate())
        }
    }
    
    func testEvaluateClosureWithTooManyArguments() {
        let subfunction = Subfunction(name: "echo", patterns: [.variable("x")], when: .bool(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.callAnon(closure, [Expression.int(7), Expression.int(8)])
            XCTAssertThrowsError(try call.evaluate())
        }
    }

    func test_evaluateClosure_nonBooleanWhenClause_throws() {
        let subfunction = Subfunction(name: "echo", patterns: [], when: .int(1), body: .bool(true))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": closure]
            let call = Expression.call("echo", [])
            XCTAssertThrowsError(try call.evaluate(context: context))
        }
    }

    func test_evaluateClosure_falseWhenClause_throws() {
        let subfunction = Subfunction(name: "echo", patterns: [], when: .bool(false), body: .bool(true))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": closure]
            let call = Expression.call("echo", [])
            XCTAssertThrowsError(try call.evaluate(context: context))
        }
    }

    func test_evaluateClosure_trueWhenClause_succeeds() {
        let subfunction = Subfunction(name: "echo", patterns: [], when: .bool(true), body: .int(9))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": closure]
            let call = Expression.call("echo", [])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.int(9), actual)
        }
    }

    func testEvaluateLambda() {
        let subfunction = Subfunction(name: nil, patterns: [.variable("x")], when: .bool(true), body: .variable("x"))
        assertNoThrow {
            let lambda = try Expression.subfunction(subfunction).evaluate()
            let call = Expression.callAnon(lambda, [Expression.int(7)])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(7), result)
        }
    }

    func test_call_missingSymbol() {
        let call = Expression.call("noSuchFunction", [])
        XCTAssertThrowsError(try call.evaluate())
    }
}
