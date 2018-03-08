import XCTest
import Song

class AssignTests: XCTestCase {

    func testDescription() {
        let constant = Expression.assign(variable: .name("foo"), value: .string("bar"))
        let actual = "\(constant)"
        XCTAssertEqual("foo: \"bar\"", actual)
    }

    func testEvaluate() {
        assertNoThrow {
            let constant = Expression.assign(variable: .name("foo"), value: .call("+", [.int(4), .int(2)]))
            let actual = try constant.evaluate()
            let expected = Expression.assign(variable: .name("foo"), value: .int(6))
            XCTAssertEqual(expected, actual)
        }
    }
}
