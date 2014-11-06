import XCTest
import Song

class PairTests: XCTestCase {
    
    let pair = Expression.Pair(Expression.Integer(0), Expression.Unit)
    
    func testConstructor() {
        switch pair {
        case let .Pair(first as Expression, second as Expression):
            let expectedFirst = Expression.Integer(0)
            let expectedSecond = Expression.Unit
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
        let compoundPair = Expression.Pair(Expression.SongString("hi"), pair)
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
    
    func testDescriptionSecond() {
        let second = Expression.Second(pair)
        let result = "\(second)"
        XCTAssertEqual("second((0, #))", result)
    }
    
    func testEvaluateSecondForNonPair() {
        let pair = Expression.Integer(1)
        let second = Expression.Second(pair)
        let result = second.evaluate()
        XCTAssertEqual(Expression.Error("requires pair"), result)
    }

    func testEvaluateSecond() {
        let pair = Expression.Variable("p")
        let second = Expression.Second(pair)
        let result = second.evaluate([
            "x": Expression.Integer(50),
            "p": Expression.Pair(Expression.Integer(0), Expression.Variable("x"))
            ])
        XCTAssertEqual(Expression.Integer(50), result)
    }
}
