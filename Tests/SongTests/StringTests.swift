import XCTest
import Song

class StringTests: XCTestCase {
    
    let string = Expression.stringValue("hello")

    func testConstructor() {
        switch string {
        case let .stringValue(value):
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
        assertNoThrow {
            let result = try string.evaluate()
            XCTAssertEqual(string, result)
        }
    }
}
