import XCTest
import Song

class CallTests: XCTestCase {
    
    func testDescription() {
        let subfunction = Subfunction(name: "echo", patterns: [Expression.variable("x"), Expression.variable("y")], when: Expression.booleanValue(true), body: Expression.variable("x"))
        assertNoThrow {
            let closure = try Expression.subfunction(subfunction).evaluate()
            let call = Expression.callAnonymous(closure: closure, arguments: [Expression.integerValue(99), Expression.integerValue(100)])
            let result = "\(call)"
            XCTAssertEqual("[() echo(x, y) When Yes = x](99, 100)", result)
        }
    }

    func testFunctionDescription() {
        let left = Expression.integerValue(5)
        let right = Expression.integerValue(9)
        let foo = Expression.call(name: "foo", arguments: [left, right])
        XCTAssertEqual("foo(5, 9)", "\(foo)")
    }

    func testEquatable_call_same_returnsTrue() {
        let left = Expression.call(name: "foo", arguments: [.integerValue(9)])
        let right = Expression.call(name: "foo", arguments: [.integerValue(9)])
        XCTAssertEqual(left, right)
    }

    func testEquatable_call_differentName_returnsFalse() {
        let left = Expression.call(name: "foo", arguments: [.integerValue(9)])
        let right = Expression.call(name: "bar", arguments: [.integerValue(9)])
        XCTAssertNotEqual(left, right)
    }

    func testEquatable_call_differentArguments_returnsFalse() {
        let left = Expression.call(name: "foo", arguments: [.integerValue(9)])
        let right = Expression.call(name: "foo", arguments: [.stringValue("hi")])
        XCTAssertNotEqual(left, right)
    }

    func testEquatable_callAnonymous_same_returnsTrue() {
        let left = Expression.callAnonymous(closure: .integerValue(9), arguments: [.integerValue(5)])
        let right = Expression.callAnonymous(closure: .integerValue(9), arguments: [.integerValue(5)])
        XCTAssertEqual(left, right)
    }

    func testEquatable_callAnonymous_differentClosure_returnsFalse() {
        let left = Expression.callAnonymous(closure: .integerValue(1), arguments: [.integerValue(5)])
        let right = Expression.callAnonymous(closure: .integerValue(9), arguments: [.integerValue(5)])
        XCTAssertNotEqual(left, right)
    }

    func testEquatable_callAnonymous_differentArguments_returnsFalse() {
        let left = Expression.callAnonymous(closure: .integerValue(9), arguments: [.integerValue(5)])
        let right = Expression.callAnonymous(closure: .integerValue(9), arguments: [.integerValue(1)])
        XCTAssertNotEqual(left, right)
    }

    func testEvaluateCallingNonClosure() {
        let call = Expression.callAnonymous(closure: Expression.integerValue(5), arguments: [])
        XCTAssertThrowsError(try call.evaluate())
    }

    func testEvaluateCallingInvalidClosure() {
        let closure = Expression.closure(closure: Expression.integerValue(5), context: Context())
        let call = Expression.callAnonymous(closure: closure, arguments: [])
        XCTAssertThrowsError(try call.evaluate())
    }

    func testEvaluateCallingFunctionReferencedInContext() {
        assertNoThrow {
            let subfunction = Subfunction(name: "five", patterns: [], when: .booleanValue(true), body: .integerValue(5))
            let function = Expression.subfunction(subfunction)
            let closure = try function.evaluate()
            let call = Expression.callAnonymous(closure: Expression.variable("f"), arguments: [])
            let result = try call.evaluate(context: ["f": [closure]])
            XCTAssertEqual(Expression.integerValue(5), result)
        }
    }
    
    func testEvaluateClosureWithoutParameters() {
        assertNoThrow {
            let subfunction = Subfunction(name: "five", patterns: [], when: .booleanValue(true), body: Expression.integerValue(5))
            let function = Expression.subfunction(subfunction)
            let closure = try function.evaluate()
            let call = Expression.callAnonymous(closure: closure, arguments: [])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.integerValue(5), result)
        }
    }
    
    func testEvaluateClosureReferencesDeclarationContext() {
        let subfunction = Subfunction(name: "getX", patterns: [], when: .booleanValue(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate(context: ["x": [.integerValue(7)]])
            let call = Expression.callAnonymous(closure: closure, arguments: [])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.integerValue(7), result)
        }
    }
    
    func testEvaluateClosureCapturesCallingContext() {
        let subfunction = Subfunction(name: "getX", patterns: [], when: .booleanValue(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.callAnonymous(closure: closure, arguments: [])
            XCTAssertEqual(Expression.integerValue(7), try call.evaluate(context: ["x": [.integerValue(7)]]))
        }
    }
    
    func testEvaluateClosureWithParameter() {
        let subfunction = Subfunction(name: "echo", patterns: [.variable("x")], when: .booleanValue(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.callAnonymous(closure: closure, arguments: [Expression.integerValue(7)])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.integerValue(7), result)
        }
    }
    
    func testEvaluateClosureWithArgumentReferencingCallingContext() {
        let subfunction = Subfunction(name: "echo", patterns: [.variable("x")], when: .booleanValue(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.callAnonymous(closure: closure, arguments: [Expression.variable("y")])
            let result = try call.evaluate(context: ["y": [.integerValue(15)]])
            XCTAssertEqual(Expression.integerValue(15), result)
        }
    }
    
    func testEvaluateClosureWithoutEnoughArguments() {
        let subfunction = Subfunction(name: "echo", patterns: [.variable("x"), .variable("y")], when: .booleanValue(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.callAnonymous(closure: closure, arguments: [Expression.integerValue(7)])
            XCTAssertThrowsError(try call.evaluate())
        }
    }
    
    func testEvaluateClosureWithTooManyArguments() {
        let subfunction = Subfunction(name: "echo", patterns: [.variable("x")], when: .booleanValue(true), body: .variable("x"))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.callAnonymous(closure: closure, arguments: [Expression.integerValue(7), Expression.integerValue(8)])
            XCTAssertThrowsError(try call.evaluate())
        }
    }

    func test_evaluateClosure_nonBooleanWhenClause_throws() {
        let subfunction = Subfunction(name: "echo", patterns: [], when: .integerValue(1), body: .booleanValue(true))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": [closure]]
            let call = Expression.call(name: "echo", arguments: [])
            XCTAssertThrowsError(try call.evaluate(context: context))
        }
    }

    func test_evaluateClosure_falseWhenClause_throws() {
        let subfunction = Subfunction(name: "echo", patterns: [], when: .booleanValue(false), body: .booleanValue(true))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": [closure]]
            let call = Expression.call(name: "echo", arguments: [])
            XCTAssertThrowsError(try call.evaluate(context: context))
        }
    }

    func test_evaluateClosure_trueWhenClause_succeeds() {
        let subfunction = Subfunction(name: "echo", patterns: [], when: .booleanValue(true), body: .integerValue(9))
        let function = Expression.subfunction(subfunction)
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": [closure]]
            let call = Expression.call(name: "echo", arguments: [])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(9), actual)
        }
    }

    // TODO
//    func testEvaluateClosureExtendsContextWithRecursiveReference() {
//        let listVar = Expression.variable("list")
//        let isUnitValue = Expression.isUnit(listVar)
//        let zero = Expression.integerValue(0)
//        let one = Expression.integerValue(1)
//        let second = Expression.second(listVar)
//        let recursiveCall = Expression.callAnonymous(closure: .variable("length"), arguments: [second])
//        let otherwise = Expression.call(name: "+", arguments: [one, recursiveCall])
//        let lengthBody = Expression.conditional(condition: isUnitValue, then: zero, otherwise: otherwise)
//        let subfunction = Subfunction(name: "length", patterns: [.variable("list")], when: .booleanValue(true), body: lengthBody)
//        let lengthFunc = Expression.subfunction(subfunction)
//        assertNoThrow {
//            let lengthClosure = try lengthFunc.evaluate()
//            let list = Expression.list([.integerValue(5)])
//            let lengthCall = Expression.callAnonymous(closure: lengthClosure, arguments: [list])
//            let result = try lengthCall.evaluate(context: ["length": [lengthClosure]])
//            XCTAssertEqual(Expression.integerValue(1), result)
//        }
//    }
    
    func testEvaluateLambda() {
        let subfunction = Subfunction(name: nil, patterns: [.variable("x")], when: .booleanValue(true), body: .variable("x"))
        assertNoThrow {
            let lambda = try Expression.subfunction(subfunction).evaluate()
            let call = Expression.callAnonymous(closure: lambda, arguments: [Expression.integerValue(7)])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.integerValue(7), result)
        }
    }

    func test_call_missingSymbol() {
        let call = Expression.call(name: "noSuchFunction", arguments: [])
        XCTAssertThrowsError(try call.evaluate())
    }
}
