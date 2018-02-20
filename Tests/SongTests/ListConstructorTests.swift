import XCTest
import Song

class ListConstructorTests: XCTestCase {

    func testDescription() {
        let listConstructor = Expression.listConstructor(.integerValue(9), .variable("xs"))
        XCTAssertEqual("[9|xs]", "\(listConstructor)")
    }
}
