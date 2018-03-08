import XCTest
import Song

class IntTests: XCTestCase {

    func test_description() {
        let int = Expression.int(-5)
        XCTAssertEqual("-5", "\(int)")
    }

    func test_evaluate() {
        assertNoThrow {
            let int = Expression.int(5)
            XCTAssertEqual(int, try int.evaluate())
        }
    }
}
