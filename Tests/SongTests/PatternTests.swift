import XCTest
import Song

class PatternTests: XCTestCase {

    lazy var context: Context = [
        "anyVariableFunc": [Expression.subfunction(Subfunction(name: "anyVariableFunc", patterns: [.anyVariable], when: .booleanValue(true), body: .stringValue("ok")))],
        "booleanLiteralFunc": [Expression.subfunction(Subfunction(name: "booleanLiteralFunc", patterns: [.booleanValue(false)], when: .booleanValue(true), body: .stringValue("ok")))],
        "numberLiteralFunc": [Expression.subfunction(Subfunction(name: "numberLiteralFunc", patterns: [.integerValue(2)], when: .booleanValue(true), body: .stringValue("ok")))],
        "listLiteralFunc": [Expression.subfunction(Subfunction(name: "listLiteralFunc", patterns: [.list([.integerValue(1), .integerValue(2)])], when: .booleanValue(true), body: .stringValue("ok")))],
        "listConstructorLiteralFunc": [Expression.subfunction(Subfunction(name: "listConstructorLiteralFunc", patterns: [.listConstructor([.integerValue(1)], .list([.integerValue(2)]))], when: .booleanValue(true), body: .stringValue("ok")))],
        "listConstructorVariableFunc": [Expression.subfunction(Subfunction(name: "listConstructorVariableFunc", patterns: [.listConstructor([.integerValue(1), .integerValue(2)], .list([.variable("xs")]))], when: .booleanValue(true), body: .stringValue("ok")))],
        "nestedListConstructorLiteralFunc": [Expression.subfunction(Subfunction(name: "nestedListConstructorLiteralFunc", patterns: [.listConstructor([.list([.integerValue(1)])], .list([.integerValue(2)]))], when: .booleanValue(true), body: .stringValue("ok")))],
        "zip": [
            Expression.subfunction(Subfunction(name: "zip", patterns: [.list([.list([]), .list([])])], when: .booleanValue(true), body: .list([]))),
            Expression.subfunction(Subfunction(name: "zip",
                                               patterns: [.list([
                                                .listConstructor([.variable("x")], .variable("xs")),
                                                .listConstructor([.variable("y")], .variable("ys"))
                                                ])],
                                               when: .booleanValue(true),
                                               body:
                .call(name: "+", arguments: [
                    .list([.list([.variable("x"), .variable("y")])]),
                    .call(name: "zip", arguments: [.list([.variable("xs"), .variable("ys")])])
                    ])
            ))],
        "variableFunc": [Expression.subfunction(Subfunction(name: "variableFunc", patterns: [.variable("x")], when: .booleanValue(true), body: .variable("x")))],
    ]
    //                                                              [[x, y]] + [xs, ys].zip

    func test_literal_wrongType_fails() {
        let call = Expression.call(name: "numberLiteralFunc", arguments: [.stringValue("two")])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_literal_arityMismatch_fails() {
        let call = Expression.call(name: "numberLiteralFunc", arguments: [.integerValue(2), .integerValue(3)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_anyVariable_match_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "anyVariableFunc", arguments: [.integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_boolLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "booleanLiteralFunc", arguments: [.booleanValue(false)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_boolLiteral_noMatch_fails() {
        let call = Expression.call(name: "booleanLiteralFunc", arguments: [.booleanValue(true)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_numberLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "numberLiteralFunc", arguments: [.integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_numberLiteral_noMatch_fails() {
        let call = Expression.call(name: "numberLiteralFunc", arguments: [.integerValue(3)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "listLiteralFunc", arguments: [.list([.integerValue(1), .integerValue(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_listLiteral_noMatch_fails() {
        let call = Expression.call(name: "listLiteralFunc", arguments: [.list([.integerValue(1)])])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listConstructorLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "listConstructorLiteralFunc", arguments: [.list([.integerValue(1), .integerValue(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_nestedListConstructorLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "nestedListConstructorLiteralFunc", arguments: [.list([.list([.integerValue(1)]), .integerValue(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_nestedList_match_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "zip", arguments: [
                .list([
                    .list([.integerValue(1), .integerValue(2)]),
                    .list([.integerValue(3), .integerValue(4)])
                    ])
                ])
            let actual = try call.evaluate(context: context)
            let expected = Expression.list([
                .list([.integerValue(1), .integerValue(3)]),
                .list([.integerValue(2), .integerValue(4)])
                ])
            XCTAssertEqual(expected, actual)
        }
    }

    func test_nestedList_argumentNotAList_fails() {
        let call = Expression.call(name: "zip", arguments: [.integerValue(1)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listConstructorLiteral_insufficentItemsToMatch_evaluates() {
        let call = Expression.call(name: "listConstructorVariableFunc", arguments: [.list([.integerValue(1)])])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listConstructorLiteral_argumentNotAList_evaluates() {
        let call = Expression.call(name: "listConstructorLiteralFunc", arguments: [.integerValue(1)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_variable_match_evaluates() {
        assertNoThrow {
            let call = Expression.call(name: "variableFunc", arguments: [.integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(2), actual)
        }
    }
}
