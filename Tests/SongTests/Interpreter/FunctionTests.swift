import XCTest
import Song

class FunctionTests: XCTestCase {

    lazy var namedFunction = makeNamedFunction()
    lazy var anonymousFunction = makeAnonymousFunction()

    func testDescriptionNamedFunction() {
        let result = "\(makeNamedFunction())"
        XCTAssertEqual("foo(a, b) = x", result)
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
        let function = Expression.function(Function(name: "foo", patterns: [.float(1.0)], when: .bool(true), body: .bool(true)))
        XCTAssertThrowsError(try function.evaluate())
    }

    func testDescriptionAnonymousFunction() {
        let result = "\(anonymousFunction)"
        XCTAssertEqual("λ(a, b) = x", result)
    }

    private func makeNamedFunction() -> Expression {
        let function = Function(name: "foo",
                                      patterns: [Expression.name("a"), Expression.name("b")],
                                      when: Expression.bool(true),
                                      body: Expression.name("x"))
        return .function(function)
    }

    private func makeAnonymousFunction() -> Expression {
        let function = Function(name: nil,
                                      patterns: [Expression.name("a"), Expression.name("b")],
                                      when: Expression.bool(true),
                                      body: Expression.name("x"))
        return .function(function)
    }
}
