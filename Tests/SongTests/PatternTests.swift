import XCTest
import Song

class PatternTests: XCTestCase {

    lazy var functions: [Subfunction] = [
        Subfunction(name: "anyVariableFunc", patterns: [.ignore], when: .bool(true), body: .stringValue("ok")),
        Subfunction(name: "booleanLiteralFunc", patterns: [.bool(false)], when: .bool(true), body: .stringValue("ok")),
        Subfunction(name: "numberLiteralFunc", patterns: [.integerValue(2)], when: .bool(true), body: .stringValue("ok")),
        Subfunction(name: "listLiteralFunc", patterns: [.list([.integerValue(1), .integerValue(2)])], when: .bool(true), body: .stringValue("ok")),
        Subfunction(name: "listConstructorLiteralFunc", patterns: [.listCons([.integerValue(1)], .list([.integerValue(2)]))], when: .bool(true), body: .stringValue("ok")),
        Subfunction(name: "listConstructorVariableFunc", patterns: [.listCons([.integerValue(1), .integerValue(2)], .list([.variable("xs")]))], when: .bool(true), body: .stringValue("ok")),
        Subfunction(name: "nestedListConstructorLiteralFunc", patterns: [.listCons([.list([.integerValue(1)])], .list([.integerValue(2)]))], when: .bool(true), body: .stringValue("ok")),
        Subfunction(name: "zip", patterns: [.list([.list([]), .list([])])], when: .bool(true), body: .list([])),
        Subfunction(name: "zip",
                    patterns: [.list([
                        .listCons([.variable("x")], .variable("xs")),
                        .listCons([.variable("y")], .variable("ys"))
                        ])],
                    when: .bool(true),
                    body: .call("+", [
                        .list([.list([.variable("x"), .variable("y")])]),
                        .call("zip", [.list([.variable("xs"), .variable("ys")])])
                        ])),
        Subfunction(name: "variableFunc", patterns: [.variable("x")], when: .bool(true), body: .variable("x")),
        Subfunction(name: "repeatedVariableFunc", patterns: [.variable("x"), .variable("x")], when: .bool(true), body: .variable("x")),
        Subfunction(name: "repeatedNestedVariableFunc",
                    patterns: [.listCons([.variable("x")], .ignore),
                               .listCons([.variable("x")], .ignore)],
                    when: .bool(true),
                    body: .variable("x")),
    ]

    var context = Context()

    override func setUp() {
        context = try! declareSubfunctions(functions)
    }

    func test_literal_wrongType_fails() {
        let call = Expression.call("numberLiteralFunc", [.stringValue("two")])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_literal_arityMismatch_fails() {
        let call = Expression.call("numberLiteralFunc", [.integerValue(2), .integerValue(3)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_anyVariable_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("anyVariableFunc", [.integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_boolLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("booleanLiteralFunc", [.bool(false)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_boolLiteral_noMatch_fails() {
        let call = Expression.call("booleanLiteralFunc", [.bool(true)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_numberLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("numberLiteralFunc", [.integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_numberLiteral_noMatch_fails() {
        let call = Expression.call("numberLiteralFunc", [.integerValue(3)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("listLiteralFunc", [.list([.integerValue(1), .integerValue(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_listLiteral_noMatch_fails() {
        let call = Expression.call("listLiteralFunc", [.list([.integerValue(1)])])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listConstructorLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("listConstructorLiteralFunc", [.list([.integerValue(1), .integerValue(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_nestedListConstructorLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("nestedListConstructorLiteralFunc", [.list([.list([.integerValue(1)]), .integerValue(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.stringValue("ok"), actual)
        }
    }

    func test_nestedList_match_evaluates() {
        assertNoThrow {

            let call = Expression.call("zip", [
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
        let call = Expression.call("zip", [.integerValue(1)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listConstructorLiteral_insufficentItemsToMatch_evaluates() {
        let call = Expression.call("listConstructorVariableFunc", [.list([.integerValue(1)])])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listConstructorLiteral_argumentNotAList_evaluates() {
        let call = Expression.call("listConstructorLiteralFunc", [.integerValue(1)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_variable_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("variableFunc", [.integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.integerValue(2), actual)
        }
    }

    func test_repeatedVariable_unequal_throws() {
        let call = Expression.call("repeatedVariableFunc", [.integerValue(2), .integerValue(3)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_repeatedVariable_equal_binds() {
        assertNoThrow {
            let call = Expression.call("repeatedVariableFunc", [.integerValue(2), .integerValue(2)])
            XCTAssertEqual(.integerValue(2), try call.evaluate(context: context))
        }
    }

    func test_repeatedVariable_float_throws() {
        let call = Expression.call("repeatedVariableFunc", [.floatValue(4.1), .floatValue(4.1)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_repeatedVariable_shadowsExistingVariable_overridesButSucceeds() {
        assertNoThrow {

            var context: Context = ["x": .integerValue(5)]

            let foo = Subfunction(name: "foo", patterns: [.variable("x"), .variable("x")], when: .bool(true), body: .variable("x"))

            context = try declareSubfunctions([Expression.subfunction(foo)], in: context)
            
            let call = Expression.call("foo", [.integerValue(2), .integerValue(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(.integerValue(2), actual)
        }
    }

    func test_repeatedVariable_nested_unequal_throws() {
        let call = Expression.call("repeatedNestedVariableFunc", [
            .list([.integerValue(5)]), .list([.integerValue(3)])
            ])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_repeatedVariable_nested_equal_binds() {
        assertNoThrow {
            let call = Expression.call("repeatedNestedVariableFunc", [
                .list([.integerValue(5)]), .list([.integerValue(5)])
                ])
            XCTAssertEqual(.integerValue(5), try call.evaluate(context: context))
        }
    }
}
