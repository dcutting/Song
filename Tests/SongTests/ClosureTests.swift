import XCTest
import Song

class ClosureTests: XCTestCase {
    
    let function = Expression.function(name: "foo", parameters: ["a", "b"], body: Expression.variable("x"))

    let context = ["x": Expression.integerValue(5), "y": Expression.stringValue("hi")]
    
    func testDescription() {
        let closure = function.evaluate(context: context)
        let result = "\(closure)"
        XCTAssertEqual("[(x = 5, y = 'hi') def foo(a, b) { x }]", result)
    }
    
    func testEvaluate() {
        let closure = function.evaluate(context: context)
        let result = closure.evaluate()
        XCTAssertEqual(closure, result)
    }
}
