import XCTest
import Song

class VariableTests: XCTestCase {
    
    let variable = SongExpression.SongVariable("n")
    
    func testConstructor() {
        switch variable {
        case let .SongVariable(token):
            XCTAssertEqual("n", token)
        default:
            XCTFail("not a variable")
        }
    }
    
    func testDescription() {
        let result = "\(variable)"
        XCTAssertEqual("n", result)
    }

    func testEvaluateBoundVariable() {
        let context = ["n": SongExpression.SongInteger(5)]
        let result = variable.evaluate(context)
        XCTAssertEqual(SongExpression.SongInteger(5), result)
    }
    
    func testEvaluateUnboundVariable() {
        let result = variable.evaluate()
        XCTAssertEqual(SongExpression.SongError("cannot evaluate n"), result)
    }
}
