import XCTest
import SongLang

class FunctionTests: XCTestCase {

    lazy var namedFunction = makeNamedFunction()
    lazy var anonymousFunction = Expression.lambda([.name("a"), .name("b")], .name("x"))

    func test_description_functionWithoutWhen() {
        let result = "\(makeNamedFunction())"
        XCTAssertEqual("foo(a, b) = x", result)
    }

    func test_description_functionWithWhen() {
        let function = Function(name: "foo",
                                patterns: [.name("a"), .name("b")],
                                when: .call("<", [.name("a"), .name("b")]),
                                body: .name("a"))
        let expr = Expression.function(function)
        XCTAssertEqual("foo(a, b) When <(a, b) = a", "\(expr)")
    }

    func test_evaluate_namedFunction_returnsClosure() {
        let context: Context = ["x": .int(5)]
        assertNoThrow {
            let actual = try namedFunction.evaluate(context: context)
            let expected = Expression.closure("foo", [namedFunction], context)
            XCTAssertEqual(expected, actual)
        }
    }

    func test_evaluate_namedFunction_shadowsExistingNonClosure_throws() {
        let context: Context = ["foo": .int(5)]
        XCTAssertThrowsError(try namedFunction.evaluate(context: context))
    }

    func test_evaluate_patternIsAFloat_throws() {
        let function = Expression.function(Function(name: "foo", patterns: [.float(1.0)], when: .yes, body: .yes))
        XCTAssertThrowsError(try function.evaluate())
    }

    func test_description_anonymousFunction() {
        let result = "\(anonymousFunction)"
        XCTAssertEqual("λ(a, b) = x", result)
    }

    private func makeNamedFunction() -> SongLang.Expression {
        let function = Function(name: "foo",
                                      patterns: [.name("a"), .name("b")],
                                      when: .yes,
                                      body: .name("x"))
        return .function(function)
    }
}
