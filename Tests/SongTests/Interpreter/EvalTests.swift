import XCTest
import SongLang

class EvalTests: XCTestCase {

    func test_description() {
        assertNoThrow {
            let function = Function(name: "echo", patterns: [.name("x"), .name("y")], when: .yes, body: .name("x"))
            let closure = try Expression.function(function).evaluate()
            let eval = Expression.eval( closure, [.int(99), .int(100)])
            XCTAssertEqual("[echo(x, y) = x](99, 100)", "\(eval)")
        }
    }

    func test_eq_callAnonymous_same_returnsTrue() {
        let left = Expression.eval(.int(9), [.int(5)])
        let right = Expression.eval(.int(9), [.int(5)])
        XCTAssertEqual(left, right)
    }

    func test_eq_callAnonymous_differentClosure_returnsFalse() {
        let left = Expression.eval(.int(1), [.int(5)])
        let right = Expression.eval(.int(9), [.int(5)])
        XCTAssertNotEqual(left, right)
    }

    func test_eq_callAnonymous_differentArguments_returnsFalse() {
        let left = Expression.eval(.int(9), [.int(5)])
        let right = Expression.eval(.int(9), [.int(1)])
        XCTAssertNotEqual(left, right)
    }

    func test_evaluate_callingNonClosure_throws() {
        let call = Expression.eval(.int(5), [])
        XCTAssertThrowsError(try call.evaluate())
    }

    func test_evaluate_callingInvalidClosure_throws() {
        let closure = Expression.closure(nil, [.int(5)], Context())
        let call = Expression.eval(closure, [])
        XCTAssertThrowsError(try call.evaluate())
    }

    func test_evaluate_callingFunctionReferencedInContext() {
        assertNoThrow {
            let function = Expression.function(Function(name: "five", patterns: [], when: .yes, body: .int(5)))
            let closure = try function.evaluate()
            let eval = Expression.eval(.name("f"), [])
            let result = try eval.evaluate(context: ["f": closure])
            XCTAssertEqual(Expression.int(5), result)
        }
    }

    func test_evaluate_closureWithoutParameters() {
        assertNoThrow {
            let function = Expression.function(Function(name: "five", patterns: [], when: .yes, body: .int(5)))
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(5), result)
        }
    }

    func test_evaluate_closureReferencesDeclarationContext() {
        let function = Expression.function(Function(name: "getX", patterns: [], when: .yes, body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate(context: ["x": .int(7)])
            let call = Expression.eval(closure, [])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(7), result)
        }
    }

    func test_evaluate_closureCapturesCallingContext() {
        let function = Expression.function(Function(name: "getX", patterns: [], when: .yes, body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [])
            XCTAssertEqual(Expression.int(7), try call.evaluate(context: ["x": .int(7)]))
        }
    }

    func test_evaluate_closureWithParameter() {
        let function = Expression.function(Function(name: "echo", patterns: [.name("x")], when: .yes, body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [.int(7)])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(7), result)
        }
    }

    func test_evaluate_closureWithArgumentReferencingCallingContext() {
        let function = Expression.function(Function(name: "echo", patterns: [.name("x")], when: .yes, body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [.name("y")])
            let result = try call.evaluate(context: ["y": .int(15)])
            XCTAssertEqual(Expression.int(15), result)
        }
    }

    func test_evaluate_closureWithoutEnoughArguments() {
        let function = Expression.function(Function(name: "echo", patterns: [.name("x"), .name("y")], when: .yes, body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [.int(7)])
            XCTAssertThrowsError(try call.evaluate())
        }
    }

    func test_evaluate_closureWithTooManyArguments() {
        let function = Expression.function(Function(name: "echo", patterns: [.name("x")], when: .yes, body: .name("x")))
        assertNoThrow {
            let closure = try function.evaluate()
            let call = Expression.eval(closure, [.int(7), .int(8)])
            XCTAssertThrowsError(try call.evaluate())
        }
    }

    func test_evaluate_lambda() {
        let function = Function(name: nil, patterns: [.name("x")], when: .yes, body: .name("x"))
        assertNoThrow {
            let lambda = try Expression.function(function).evaluate()
            let call = Expression.eval(lambda, [.int(7)])
            let result = try call.evaluate()
            XCTAssertEqual(Expression.int(7), result)
        }
    }
}
