import XCTest
import Song

class VariableTests: XCTestCase {
    
    let variable = Expression.variable("n")
    
    func testConstructor() {
        switch variable {
        case let .variable(token):
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
        let context = ["n": Expression.integerValue(5)]
        let result = variable.evaluate(context: context)
        XCTAssertEqual(Expression.integerValue(5), result)
    }
    
    func testEvaluateUnboundVariable() {
        let result = variable.evaluate()
        XCTAssertEqual(Expression.error("cannot evaluate n"), result)
    }
}
