import XCTest
import Song

class FunctionTests: XCTestCase {

    let namedFunction = Expression.function(name: "foo", parameters: ["a", "b"], body: Expression.variable("x"))
    let anonymousFunction = Expression.function(name: nil, parameters: ["a", "b"], body: Expression.variable("x"))

    func testDescriptionNamedFunction() {
        let result = "\(namedFunction)"
        XCTAssertEqual("def foo(a, b) { x }", result)
    }

    func testEvaluateNamedFunction() {
        let context = ["x": Expression.integerValue(5)]
        let result = namedFunction.evaluate(context: context)
        let closure = Expression.closure(function: namedFunction, context: context)
        XCTAssertEqual(closure, result)
    }
    
    func testDescriptionAnonymousFunction() {
        let result = "\(anonymousFunction)"
        XCTAssertEqual("λ(a, b) { x }", result)
    }
}
