import XCTest

class IntegerValueTests: XCTestCase {

    let integer = Expression.IntegerValue(5)

    func testConstructor() {
        switch integer {
        case let .IntegerValue(value):
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
        let left = Expression.IntegerValue(5)
        let right = Expression.IntegerValue(9)
        let plus = Expression.Plus(left, right)
        let result = "\(plus)"
        XCTAssertEqual("5 + 9", result)
    }
    
    func testPlusNonIntegerValue() {
        let nonIntegerValue = Expression.Variable("x")
        let plus = Expression.Plus(integer, nonIntegerValue)
        let result = plus.evaluate(context: ["x": Expression.StringValue("hi")])
        XCTAssertEqual(Expression.Error("cannot add 5 to 'hi'"), result)
    }

    func testPlus() {
        let leftIntegerValue = Expression.Variable("x")
        let rightIntegerValue = Expression.Variable("y")
        let plus = Expression.Plus(leftIntegerValue, rightIntegerValue)
        let result = plus.evaluate(context: ["x": Expression.IntegerValue(9), "y": Expression.IntegerValue(5)])
        XCTAssertEqual(Expression.IntegerValue(14), result)
    }
}
