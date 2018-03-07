import XCTest
import Song

class ConstantTests: XCTestCase {

    func testDescription() {
        let constant = Expression.assign(variable: .variable("foo"), value: .stringValue("bar"))
        let actual = "\(constant)"
        XCTAssertEqual("foo: \"bar\"", actual)
    }

    func testEvaluate() {
        assertNoThrow {
            let constant = Expression.assign(variable: .variable("foo"), value: .call("+", [.integerValue(4), .integerValue(2)]))
            let actual = try constant.evaluate()
            let expected = Expression.assign(variable: .variable("foo"), value: .integerValue(6))
            XCTAssertEqual(expected, actual)
        }
    }
}
