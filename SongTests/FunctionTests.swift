import XCTest
import Song

class FunctionTests: XCTestCase {

    let namedFunction = Expression.Function(name: "foo", parameters: ["a", "b"], body: Expression.Variable("x"))
    let anonymousFunction = Expression.Function(name: nil, parameters: ["a", "b"], body: Expression.Variable("x"))

    func testDescriptionNamedFunction() {
        let result = "\(namedFunction)"
        XCTAssertEqual("def foo(a, b) { x }", result)
    }

    func testEvaluateNamedFunction() {
        let context = ["x": Expression.IntegerValue(5)]
        let result = namedFunction.evaluate(context)
        let closure = Expression.Closure(function: namedFunction, context: context)
        XCTAssertEqual(closure, result)
    }
    
    func testDescriptionAnonymousFunction() {
        let result = "\(anonymousFunction)"
        XCTAssertEqual("lambda(a, b) { x }", result)
    }
}
