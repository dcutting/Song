import XCTest
import Song

class VariableTests: XCTestCase {
    
    let variable = Expression.name("n")
    
    func test_description_ignore() {
        XCTAssertEqual("_", "\(Expression.ignore)")
    }

    func test_description_variable() {
        let result = "\(variable)"
        XCTAssertEqual("n", result)
    }

    func test_evaluate_boundVariable() {
        let context: Context = ["n": .int(5)]
        assertNoThrow {
            let result = try variable.evaluate(context: context)
            XCTAssertEqual(Expression.int(5), result)
        }
    }
    
    func test_evaluate_unboundVariable() {
        XCTAssertThrowsError(try variable.evaluate())
    }
}
