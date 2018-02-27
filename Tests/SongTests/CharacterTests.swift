import XCTest
import Song

class CharacterTests: XCTestCase {

    func test_description() {
        let char = Expression.character("A")
        XCTAssertEqual("'A'", "\(char)")
    }

    func test_description_escaped() {
        let char = Expression.character("\'")
        XCTAssertEqual("'\\''", "\(char)")
    }

    func testEvaluate() {
        assertNoThrow {
            let char = Expression.character("$")
            XCTAssertEqual(char, try char.evaluate())
        }
    }
}
