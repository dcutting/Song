import XCTest
import SongLang

class AssignTests: XCTestCase {

    func test_description() {
        let assign = Expression.assign(variable: .name("foo"), value: .string("bar"))
        XCTAssertEqual("foo: \"bar\"", "\(assign)")
    }

    func test_evaluate() {
        assertNoThrow {
            let assign = Expression.assign(variable: .name("foo"), value: .call("+", [.int(4), .int(2)]))
            let expected = Expression.assign(variable: .name("foo"), value: .int(6))
            XCTAssertEqual(expected, try assign.evaluate(context: .builtIns))
        }
    }
}
