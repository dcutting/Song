import XCTest
import Song

class StringTests: XCTestCase {
    
    let string = SongExpression.SongString("hello")

    func testConstructor() {
        switch string {
        case let .SongString(value):
            XCTAssertEqual("hello", value)
        default:
            XCTFail("not a string")
        }
    }
    
    func testDescription() {
        let result = "\(string)"
        XCTAssertEqual("'hello'", result)
    }
    
    func testEvaluate() {
        let result = string.evaluate()
        XCTAssertEqual(string, result)
    }
}
