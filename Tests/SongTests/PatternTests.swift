import XCTest
import Song

class PatternTests: XCTestCase {

    lazy var context: Context = [
        "anyParameterFunc": [Expression.subfunction(Subfunction(name: "anyParameterFunc", patterns: [.anyVariable], when: .booleanValue(true), body: .stringValue("ok")))],
        "intLiteralFunc": [Expression.subfunction(Subfunction(name: "intLiteralFunc", patterns: [.integerValue(2)], when: .booleanValue(true), body: .stringValue("ok")))],
        "listLiteralFunc": [Expression.subfunction(Subfunction(name: "listLiteralFunc", patterns: [.list([.integerValue(1), .integerValue(2)])], when: .booleanValue(true), body: .stringValue("ok")))],
        "variableFunc": [Expression.subfunction(Subfunction(name: "variableFunc", patterns: [.variable("x")], when: .booleanValue(true), body: .variable("x")))],
        "listConstructorListeralFunc": [Expression.subfunction(Subfunction(name: "listConstructorListeralFunc", patterns: [.listConstructor([.integerValue(1)], .list([.integerValue(2)]))], when: .booleanValue(true), body: .stringValue("ok")))],
    ]

    func test_anyMatch_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "anyParameterFunc", arguments: [.integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_intLiteralMatches_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "intLiteralFunc", arguments: [.integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_listLiteralMatches_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "listLiteralFunc", arguments: [.list([.integerValue(1), .integerValue(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_listConstructorLiteralMatches_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "listConstructorListeralFunc", arguments: [.list([.integerValue(1), .integerValue(2)])])
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
