import XCTest
import Song

class PairTests: XCTestCase {
    
    let pair = SongExpression.SongPair(SongExpression.SongInteger(0), SongExpression.SongUnit)
    
    func testConstructor() {
        switch pair {
        case let .SongPair(first as SongExpression, second as SongExpression):
            let expectedFirst = SongExpression.SongInteger(0)
            let expectedSecond = SongExpression.SongUnit
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
        let compoundPair = SongExpression.SongPair(SongExpression.SongString("hi"), pair)
        let result = "\(compoundPair)"
        XCTAssertEqual("('hi', (0, #))", result)
    }
    
    func testEvaluate() {
        let result = pair.evaluate()
        XCTAssertEqual(pair, result)
    }
    
    func testDescriptionSecond() {
        let second = SongExpression.SongSecond(pair)
        let result = "\(second)"
        XCTAssertEqual("second((0, #))", result)
    }
    
    func testEvaluateSecondForNonPair() {
        let pair = SongExpression.SongInteger(1)
        let second = SongExpression.SongSecond(pair)
        let result = second.evaluate()
        XCTAssertEqual(SongExpression.SongError("requires pair"), result)
    }

    func testEvaluateSecond() {
        let pair = SongExpression.SongVariable("p")
        let second = SongExpression.SongSecond(pair)
        let result = second.evaluate([
            "x": SongExpression.SongInteger(50),
            "p": SongExpression.SongPair(SongExpression.SongInteger(0), SongExpression.SongVariable("x"))
            ])
        XCTAssertEqual(SongExpression.SongInteger(50), result)
    }
}
