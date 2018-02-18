import XCTest
import Song

class FunctionTests: XCTestCase {

    lazy var namedFunction = makeNamedFunction()
    lazy var anonymousFunction = makeAnonymousFunction()

    func testDescriptionNamedFunction() {
        let result = "\(makeNamedFunction())"
        XCTAssertEqual("def foo(a, b) { x }", result)
    }

    func testEvaluateNamedFunction() {
        let context = ["x": Expression.integerValue(5)]
        assertNoThrow {
            let result = try namedFunction.evaluate(context: context)
            let closure = Expression.callAnonymous(closure: namedFunction, arguments: [])
            XCTAssertEqual(closure, result)
        }
    }
    
    func testDescriptionAnonymousFunction() {
        let result = "\(anonymousFunction)"
        XCTAssertEqual("λ(a, b) { x }", result)
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
