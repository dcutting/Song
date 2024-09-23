import XCTest
import SongLang

class FloatTests: XCTestCase {

    func test_description() {
        let float = Expression.float(5.3)
        XCTAssertEqual("5.3", "\(float)")
    }

    func test_evaluate() {
        assertNoThrow {
            let float = Expression.float(5.3)
            XCTAssertEqual(float, try float.evaluate())
        }
    }

    func test_eq_throws() {
        let a = Expression.float(5.0)
        let b = Expression.float(5.0)
        let call = Expression.call("Eq", [a, b])
        XCTAssertThrowsError(try call.evaluate())
    }
}
