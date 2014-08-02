import XCTest
import Song

class ClosureTests: XCTestCase {
    
    let function = SongExpression.SongFunction(name: "foo", parameters: ["a", "b"], body: SongExpression.SongVariable("x"))

    let context = ["x": SongExpression.SongInteger(5), "y": SongExpression.SongString("hi")]
    
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
