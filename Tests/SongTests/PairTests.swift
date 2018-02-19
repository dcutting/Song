import XCTest
import Song

class PairTests: XCTestCase {
    
    let pair = Expression.pair(Expression.integerValue(0), Expression.unitValue)
    
    func testConstructor() {
        switch pair {
        case let .pair(first, second):
            let expectedFirst = Expression.integerValue(0)
            let expectedSecond = Expression.unitValue
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
        let compoundPair = Expression.pair(Expression.stringValue("hi"), pair)
        let result = "\(compoundPair)"
        XCTAssertEqual("(\"hi\", (0, #))", result)
    }
    
    func testEvaluate() {
        assertNoThrow {
            let result = try pair.evaluate()
            XCTAssertEqual(pair, result)
        }
    }
    
    func testDescriptionFirst() {
        let first = Expression.first(pair)
        let result = "\(first)"
        XCTAssertEqual("first((0, #))", result)
    }
    
    func testEvaluateFirstForNonPair() {
        let pair = Expression.integerValue(1)
        let first = Expression.first(pair)
        XCTAssertThrowsError(try first.evaluate())
    }
    
    func testEvaluateFirst() {
        let pair = Expression.variable("p")
        let first = Expression.first(pair)
        assertNoThrow {
            let result = try first.evaluate(context: [
                "x": Expression.integerValue(60),
                "p": Expression.pair(Expression.variable("x"), Expression.integerValue(0))
                ])
            XCTAssertEqual(Expression.integerValue(60), result)
        }
    }

    func testDescriptionSecond() {
        let second = Expression.second(pair)
        let result = "\(second)"
        XCTAssertEqual("second((0, #))", result)
    }
    
    func testEvaluateSecondForNonPair() {
        let pair = Expression.integerValue(1)
        let second = Expression.second(pair)
        XCTAssertThrowsError(try second.evaluate())
    }

    func testEvaluateSecond() {
        let pair = Expression.variable("p")
        let second = Expression.second(pair)
        assertNoThrow {
            let result = try second.evaluate(context: [
                "x": Expression.integerValue(50),
                "p": Expression.pair(Expression.integerValue(0), Expression.variable("x"))
                ])
            XCTAssertEqual(Expression.integerValue(50), result)
        }
    }
}
