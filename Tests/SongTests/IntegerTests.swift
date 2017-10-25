import XCTest
import Song

class IntegerValueTests: XCTestCase {

    let integer = Expression.integerValue(5)

    func testConstructor() {
        switch integer {
        case let .integerValue(value):
            XCTAssertEqual(5, value)
        default:
            XCTFail("not an integer")
        }
    }
    
    func testDescription() {
        let result = "\(integer)"
        XCTAssertEqual("5", result)
    }

    func testEvaluate() {
        let result = integer.evaluate()
        XCTAssertEqual(integer, result)
    }
    
    func testPlusDescription() {
        let left = Expression.integerValue(5)
        let right = Expression.integerValue(9)
        let plus = Expression.plus(left, right)
        let result = "\(plus)"
        XCTAssertEqual("5 + 9", result)
    }
    
    func testPlusNonIntegerValue() {
        let nonIntegerValue = Expression.variable("x")
        let plus = Expression.plus(integer, nonIntegerValue)
        let result = plus.evaluate(context: ["x": Expression.stringValue("hi")])
        XCTAssertEqual(Expression.error("cannot add 5 to 'hi'"), result)
    }

    func testPlus() {
        let leftIntegerValue = Expression.variable("x")
        let rightIntegerValue = Expression.variable("y")
        let plus = Expression.plus(leftIntegerValue, rightIntegerValue)
        let result = plus.evaluate(context: ["x": Expression.integerValue(9), "y": Expression.integerValue(5)])
        XCTAssertEqual(Expression.integerValue(14), result)
    }
}
