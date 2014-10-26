import XCTest
import Song

class IntegerTests: XCTestCase {

    let integer = SongExpression.SongInteger(5)

    func testConstructor() {
        switch integer {
        case let .SongInteger(value):
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
    
    func testPlusNonIntegerRight() {
        let nonInteger = SongExpression.SongVariable("x")
        let plus = SongExpression.SongPlus(integer, nonInteger)
        let result = plus.evaluate([ "x": SongExpression.SongString("hi") ])
        XCTAssertEqual(SongExpression.SongError("cannot add non-integer to integer"), result)
    }

    func testPlus() {
        let leftInteger = SongExpression.SongVariable("x")
        let rightInteger = SongExpression.SongVariable("y")
        let plus = SongExpression.SongPlus(leftInteger, rightInteger)
        let result = plus.evaluate([ "x": SongExpression.SongInteger(9), "y": SongExpression.SongInteger(5) ])
        XCTAssertEqual(SongExpression.SongInteger(14), result)
    }
}
