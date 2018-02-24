import XCTest
import Song

class ScopeTests: XCTestCase {

    func test_description() {
        let scope = Expression.scope([.integerValue(1), .integerValue(2)])
        XCTAssertEqual("scope (1, 2)", "\(scope)")
    }
}
