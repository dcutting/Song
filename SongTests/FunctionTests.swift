import XCTest
import Song

class FunctionTests: XCTestCase {

    let function = SongExpression.SongFunction(name: "foo", parameters: ["a", "b"], body: SongExpression.SongVariable("x"))

    func testDescription() {
        let result = "\(function)"
        XCTAssertEqual("def foo(a, b) { x }", result)
    }

    func testEvaluate() {
        let context = ["x": SongExpression.SongInteger(5)]
        let result = function.evaluate(context)
        let closure = SongExpression.SongClosure(function: function, context: context)
        XCTAssertEqual(closure, result)
    }
}
