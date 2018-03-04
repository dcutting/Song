import XCTest
import Song

class TruncateConversionTests: XCTestCase {
    
    func test_truncate_int_returnsInt() {
        assertNoThrow {
            let input: IntType = 99
            let call = Expression.call(name: "truncate", arguments: [.integerValue(input)])
            XCTAssertEqual(.integerValue(99), try call.evaluate())
        }
    }

    func test_truncate_expressionEvaluatingToNumber_returnsInt() {
        assertNoThrow {
            let context: Context = ["x": .floatValue(-5.2)]
            let variable = Expression.variable("x")
            let call = Expression.call(name: "truncate", arguments: [variable])
            XCTAssertEqual(.integerValue(-5), try call.evaluate(context: context))
        }
    }

    func test_truncate_wrongNumberOfArguments_throws() {
        let call = Expression.call(name: "truncate", arguments: [])
        XCTAssertThrowsError(try call.evaluate())
    }
}
