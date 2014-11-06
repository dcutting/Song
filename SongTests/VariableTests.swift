import XCTest
import Song

class VariableTests: XCTestCase {
    
    let variable = Expression.Variable("n")
    
    func testConstructor() {
        switch variable {
        case let .Variable(token):
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
        let context = ["n": Expression.Integer(5)]
        let result = variable.evaluate(context)
        XCTAssertEqual(Expression.Integer(5), result)
    }
    
    func testEvaluateUnboundVariable() {
        let result = variable.evaluate()
        XCTAssertEqual(Expression.Error("cannot evaluate n"), result)
    }
}
