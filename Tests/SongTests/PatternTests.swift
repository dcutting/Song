import XCTest
import Song

class PatternTests: XCTestCase {

    lazy var context: Context = [
        "anyParameterFunc": [Expression.subfunction(Subfunction(name: "anyParameterFunc", patterns: [.anyVariable], when: .booleanValue(true), body: .stringValue("ok")))],
        "intLiteralFunc": [Expression.subfunction(Subfunction(name: "intLiteralFunc", patterns: [.integerValue(2)], when: .booleanValue(true), body: .stringValue("ok")))],
        "listLiteralFunc": [Expression.subfunction(Subfunction(name: "listLiteralFunc", patterns: [.list([.integerValue(1), .integerValue(2)])], when: .booleanValue(true), body: .stringValue("ok")))],
        "variableFunc": [Expression.subfunction(Subfunction(name: "variableFunc", patterns: [.variable("x")], when: .booleanValue(true), body: .variable("x")))],
        "listConstructorLiteralFunc": [Expression.subfunction(Subfunction(name: "listConstructorLiteralFunc", patterns: [.listConstructor([.integerValue(1)], .list([.integerValue(2)]))], when: .booleanValue(true), body: .stringValue("ok")))],
        "listConstructorVariableFunc": [Expression.subfunction(Subfunction(name: "listConstructorVariableFunc", patterns: [.listConstructor([.integerValue(1), .integerValue(2)], .list([.variable("xs")]))], when: .booleanValue(true), body: .stringValue("ok")))],
    ]

    func test_any_matches_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "anyParameterFunc", arguments: [.integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_intLiteral_matches_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "intLiteralFunc", arguments: [.integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_listLiteral_matches_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "listLiteralFunc", arguments: [.list([.integerValue(1), .integerValue(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_listConstructorLiteral_matches_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "listConstructorLiteralFunc", arguments: [.list([.integerValue(1), .integerValue(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_listConstructorLiteral_insufficentItemsToMatch_evaluates() {
        let call = Expression.call(name: "listConstructorVariableFunc", arguments: [.list([.integerValue(1)])])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listConstructorLiteral_argumentNotAList_evaluates() {
        let call = Expression.call(name: "listConstructorLiteralFunc", arguments: [.integerValue(1)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_literal_noMatch_fails() {
        let call = Expression.call(name: "intLiteralFunc", arguments: [.integerValue(3)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_literal_wrongType_fails() {
        let call = Expression.call(name: "intLiteralFunc", arguments: [.stringValue("two")])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_literal_arityMismatch_fails() {
        let call = Expression.call(name: "intLiteralFunc", arguments: [.integerValue(2), .integerValue(3)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }
}
