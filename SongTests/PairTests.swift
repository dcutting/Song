import XCTest
import Song

class PairTests: XCTestCase {
    
    let pair = Expression.Pair(Expression.IntegerValue(0), Expression.UnitValue)
    
    func testConstructor() {
        switch pair {
        case let .Pair(first, second):
            let expectedFirst = Expression.IntegerValue(0)
            let expectedSecond = Expression.UnitValue
            XCTAssertEqual(expectedFirst, first)
            XCTAssertEqual(expectedSecond, second)
        default:
            XCTFail("not a pair")
        }
    }
    
    func testDescription() {
        let result = "\(pair)"
        XCTAssertEqual("(0, #)", result)
    }
    
    func testDescriptionSubPair() {
        let compoundPair = Expression.Pair(Expression.StringValue("hi"), pair)
        let result = "\(compoundPair)"
        XCTAssertEqual("('hi', (0, #))", result)
    }
    
    func testEvaluate() {
        let result = pair.evaluate()
        XCTAssertEqual(pair, result)
    }
    
    func testDescriptionFirst() {
        let first = Expression.First(pair)
        let result = "\(first)"
        XCTAssertEqual("first((0, #))", result)
    }
    
    func testEvaluateFirstForNonPair() {
        let pair = Expression.IntegerValue(1)
        let first = Expression.First(pair)
        let result = first.evaluate()
        XCTAssertEqual(Expression.Error("requires pair"), result)
    }
    
    func testEvaluateFirst() {
        let pair = Expression.Variable("p")
        let first = Expression.First(pair)
        let result = first.evaluate([
            "x": Expression.IntegerValue(60),
            "p": Expression.Pair(Expression.Variable("x"), Expression.IntegerValue(0))
            ])
        XCTAssertEqual(Expression.IntegerValue(60), result)
    }

    func testDescriptionSecond() {
        let second = Expression.Second(pair)
        let result = "\(second)"
        XCTAssertEqual("second((0, #))", result)
    }
    
    func testEvaluateSecondForNonPair() {
        let pair = Expression.IntegerValue(1)
        let second = Expression.Second(pair)
        let result = second.evaluate()
        XCTAssertEqual(Expression.Error("requires pair"), result)
    }

    func testEvaluateSecond() {
        let pair = Expression.Variable("p")
        let second = Expression.Second(pair)
        let result = second.evaluate([
            "x": Expression.IntegerValue(50),
            "p": Expression.Pair(Expression.IntegerValue(0), Expression.Variable("x"))
            ])
        XCTAssertEqual(Expression.IntegerValue(50), result)
    }
}
