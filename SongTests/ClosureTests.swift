import XCTest
import Song

class ClosureTests: XCTestCase {
    
    let function = Expression.Function(name: "foo", parameters: ["a", "b"], body: Expression.Variable("x"))

    let context = ["x": Expression.Integer(5), "y": Expression.SongString("hi")]
    
    func testDescription() {
        let closure = function.evaluate(context)
        let result = "\(closure)"
        XCTAssertEqual("[(x = 5, y = 'hi') def foo(a, b) { x }]", result)
    }
    
    func testEvaluate() {
        let closure = function.evaluate(context)
        let result = closure.evaluate()
        XCTAssertEqual(closure, result)
    }
}
