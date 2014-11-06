import XCTest
import Song

class FunctionTests: XCTestCase {

    let function = Expression.Function(name: "foo", parameters: ["a", "b"], body: Expression.Variable("x"))

    func testDescription() {
        let result = "\(function)"
        XCTAssertEqual("def foo(a, b) { x }", result)
    }

    func testEvaluate() {
        let context = ["x": Expression.Integer(5)]
        let result = function.evaluate(context)
        let closure = Expression.Closure(function: function, context: context)
        XCTAssertEqual(closure, result)
    }
}
