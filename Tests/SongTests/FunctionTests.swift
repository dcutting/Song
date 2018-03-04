import XCTest
import Song

class FunctionTests: XCTestCase {

    lazy var namedFunction = makeNamedFunction()
    lazy var anonymousFunction = makeAnonymousFunction()

    func testDescriptionNamedFunction() {
        let result = "\(makeNamedFunction())"
        XCTAssertEqual("foo(a, b) When Yes = x", result)
    }

    func testEvaluateNamedFunction() {
        let context: Context = ["x": .integerValue(5)]
        assertNoThrow {
            let result = try namedFunction.evaluate(context: context)
            let closure = Expression.closure("foo", [namedFunction], context)
            XCTAssertEqual(closure, result)
        }
    }

    func test_evaluate_patternIsAFloat_throws() {
        let subfunction = Subfunction(name: "foo", patterns: [.floatValue(1.0)], when: .booleanValue(true), body: .booleanValue(true))
        let function = Expression.subfunction(subfunction)
        XCTAssertThrowsError(try function.evaluate())
    }

    func testDescriptionAnonymousFunction() {
        let result = "\(anonymousFunction)"
        XCTAssertEqual("λ(a, b) = x", result)
    }

    private func makeNamedFunction() -> Expression {
        let subfunction = Subfunction(name: "foo",
                                      patterns: [Expression.variable("a"), Expression.variable("b")],
                                      when: Expression.booleanValue(true),
                                      body: Expression.variable("x"))
        return .subfunction(subfunction)
    }

    private func makeAnonymousFunction() -> Expression {
        let subfunction = Subfunction(name: nil,
                                      patterns: [Expression.variable("a"), Expression.variable("b")],
                                      when: Expression.booleanValue(true),
                                      body: Expression.variable("x"))
        return .subfunction(subfunction)
    }
}
