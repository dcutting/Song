import XCTest
import Song

class BuiltinFunctionTests: XCTestCase {

    func testPlusNonIntegerValue() {
        let integer = Expression.integerValue(5)
        let nonIntegerValue = Expression.variable("x")
        let plus = Expression.call(name: "+", arguments: [integer, nonIntegerValue])
        XCTAssertThrowsError(try plus.evaluate(context: ["x": Expression.stringValue("hi")]))
    }

    func testPlus() {
        let left = Expression.variable("x")
        let right = Expression.variable("y")
        let plus = Expression.call(name: "+", arguments: [left, right])
        assertNoThrow {
            let result = try plus.evaluate(context: ["x": Expression.integerValue(9), "y": Expression.integerValue(5)])
            XCTAssertEqual(Expression.integerValue(14), result)
        }
    }
}
