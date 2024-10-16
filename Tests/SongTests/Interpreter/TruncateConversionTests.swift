import XCTest
import SongLang

class TruncateConversionTests: XCTestCase {
    
    func test_truncate_int_returnsInt() {
        assertNoThrow {
            let input: IntType = 99
            let call = Expression.call("truncate", [.int(input)])
            XCTAssertEqual(.int(99), try call.evaluate(context: .builtIns))
        }
    }

    func test_truncate_expressionEvaluatingToNumber_returnsInt() {
        assertNoThrow {
            let context = Context.builtIns.extend(name: "x", value: .float(-5.2))
            let variable = Expression.name("x")
            let call = Expression.call("truncate", [variable])
            XCTAssertEqual(.int(-5), try call.evaluate(context: context))
        }
    }

    func test_truncate_wrongNumberOfArguments_throws() {
        let call = Expression.call("truncate", [])
        XCTAssertThrowsError(try call.evaluate(context: .builtIns))
    }
}
