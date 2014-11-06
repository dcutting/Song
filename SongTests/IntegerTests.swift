import XCTest
import Song

class IntegerTests: XCTestCase {

    let integer = Expression.Integer(5)

    func testConstructor() {
        switch integer {
        case let .Integer(value):
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
        let left = Expression.Integer(5)
        let right = Expression.Integer(9)
        let plus = Expression.Plus(left, right)
        let result = "\(plus)"
        XCTAssertEqual("5 + 9", result)
    }
    
    func testPlusNonInteger() {
        let nonInteger = Expression.Variable("x")
        let plus = Expression.Plus(integer, nonInteger)
        let result = plus.evaluate(["x": Expression.SongString("hi")])
        XCTAssertEqual(Expression.Error("cannot add 5 to 'hi'"), result)
    }

    func testPlus() {
        let leftInteger = Expression.Variable("x")
        let rightInteger = Expression.Variable("y")
        let plus = Expression.Plus(leftInteger, rightInteger)
        let result = plus.evaluate(["x": Expression.Integer(9), "y": Expression.Integer(5)])
        XCTAssertEqual(Expression.Integer(14), result)
    }
}
