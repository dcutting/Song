import XCTest
@testable import SongLang

class ContextTests: XCTestCase {

    func test_isEqual_empty_returnsTrue() {
        let left = Context.empty
        let right = Context.empty
        XCTAssertEqual(left, right)
    }

    func test_isEqual_simple_same_returnsTrue() {
        let left: Context = ["a": .string("hi"), "b": .yes]
        let right: Context = ["a": .string("hi"), "b": .yes]
        XCTAssertEqual(left, right)
    }

    func test_isEqual_simple_different_returnsFalse() {
        let left: Context = ["a": .string("hi")]
        let right: Context = ["a": .string("bye")]
        XCTAssertNotEqual(left, right)
    }

    func test_isEqual_simple_differentKeys_returnsFalse() {
        let left: Context = ["a": .int(4)]
        let right: Context = ["b": .int(4)]
        XCTAssertNotEqual(left, right)
    }

    func test_call_contextsAreNotDynamicallyScoped() {
        let foo = Function(name: "foo", patterns: [], when: .yes, body: .name("n"))
        let bar = Function(name: "bar", patterns: [.name("n")], when: .yes, body: .call("foo", []))
        let context = try! declareSubfunctions([foo, bar])
        let call = Expression.call("bar", [.int(5)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_scopeCall_tailCallHasLexicalScope() {
        let foo = Function(name: "foo", patterns: [], when: .yes, body: .name("n"))
        let context = try! declareSubfunctions([foo])
        let scope = Expression.scope([.assign(variable: .name("n"), value: .int(5)), .call("foo", [])])
        XCTAssertThrowsError(try scope.evaluate(context: Context.empty.extend(with: context)))
    }

    func test_scopeCall_middleCallHasLexicalScope() {
        let foo = Function(name: "foo", patterns: [], when: .yes, body: .name("n"))
        let context = try! declareSubfunctions([foo])
        let scope = Expression.scope([.assign(variable: .name("n"), value: .int(5)), .call("foo", []), .yes])
        XCTAssertThrowsError(try scope.evaluate(context: Context.empty.extend(with: context)))
    }

    func test_call_globalsDefinedLaterAreAccessible() {
        assertNoThrow {
            let foo = Function(name: "foo", patterns: [], when: .yes, body: .name("n"))
            var context = try declareSubfunctions([foo])
            context = context.extend(name: "n", value: .int(5))
            let call = Expression.call("foo", [])
            XCTAssertEqual(Expression.int(5), try call.evaluate(context: context))
        }
    }

    func test_describeContext() {
        let context: Context = ["foo": .int(5), "bar": .yes]
        let actual = describe(context: context)
        let expected = "bar: Yes, foo: 5"
        XCTAssertEqual(expected, actual)
    }
}
