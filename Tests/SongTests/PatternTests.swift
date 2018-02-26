import XCTest
import Song

class PatternTests: XCTestCase {

    let intLiteralFunc = Expression.subfunction(Subfunction(name: "intLiteralFunc", patterns: [.integerValue(2)], when: .booleanValue(true), body: .stringValue("ok")))
    let variableFunc = Expression.subfunction(Subfunction(name: "variableFunc", patterns: [.variable("x")], when: .booleanValue(true), body: .variable("x")))
    lazy var context: Context = ["intLiteralFunc": [intLiteralFunc], "variableFunc": [variableFunc]]

    func test_literalMatches_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "intLiteralFunc", arguments: [.integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_literalDoesNotMatch_fails() {
        let call = Expression.call(name: "intLiteralFunc", arguments: [.integerValue(3)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_literalOfWrongType_fails() {
        let call = Expression.call(name: "intLiteralFunc", arguments: [.stringValue("two")])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }
}
