import XCTest
@testable import SongLang

class CallTests: XCTestCase {
    
    func test_description() {
        let foo = Expression.call("foo", [.int(5), .int(9)])
        XCTAssertEqual("foo(5, 9)", "\(foo)")
    }

    func test_eq_call_same_returnsTrue() {
        let left = Expression.call("foo", [.int(9)])
        let right = Expression.call("foo", [.int(9)])
        XCTAssertEqual(left, right)
    }

    func test_eq_call_differentName_returnsFalse() {
        let left = Expression.call("foo", [.int(9)])
        let right = Expression.call("bar", [.int(9)])
        XCTAssertNotEqual(left, right)
    }

    func test_eq_call_differentArguments_returnsFalse() {
        let left = Expression.call("foo", [.int(9)])
        let right = Expression.call("foo", [.string("hi")])
        XCTAssertNotEqual(left, right)
    }

    func test_evaluate_closure_nonBooleanWhenClause_throws() {
        let function = Expression.function(Function(name: "echo", patterns: [], when: .int(1), body: .yes))
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": closure]
            let call = Expression.call("echo", [])
            XCTAssertThrowsError(try call.evaluate(context: context))
        }
    }

    func test_evaluate_closure_falseWhenClause_throws() {
        let function = Expression.function(Function(name: "echo", patterns: [], when: .no, body: .yes))
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": closure]
            let call = Expression.call("echo", [])
            XCTAssertThrowsError(try call.evaluate(context: context))
        }
    }

    func test_evaluate_closure_trueWhenClause_succeeds() {
        let function = Expression.function(Function(name: "echo", patterns: [], when: .yes, body: .int(9)))
        assertNoThrow {
            let closure = try function.evaluate()
            let context: Context = ["echo": closure]
            let call = Expression.call("echo", [])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.int(9), actual)
        }
    }

    func test_call_missingSymbol() {
        let call = Expression.call("noSuchFunction", [])
        XCTAssertThrowsError(try call.evaluate())
    }
}
