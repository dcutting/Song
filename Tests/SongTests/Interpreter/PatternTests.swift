import XCTest
import SongLang

class PatternTests: XCTestCase {

    lazy var functions: [Function] = [
        Function(name: "ignoreVariableFunc", patterns: [.ignore], when: .yes, body: .string("ok")),
        Function(name: "booleanLiteralFunc", patterns: [.no], when: .yes, body: .string("ok")),
        Function(name: "numberLiteralFunc", patterns: [.int(2)], when: .yes, body: .string("ok")),
        Function(name: "listLiteralFunc", patterns: [.list([.int(1), .int(2)])], when: .yes, body: .string("ok")),
        Function(name: "listConstructorLiteralFunc", patterns: [.cons([.int(1)], .list([.int(2)]))], when: .yes, body: .string("ok")),
        Function(name: "listConstructorVariableFunc", patterns: [.cons([.int(1), .int(2)], .list([.name("xs")]))], when: .yes, body: .string("ok")),
        Function(name: "nestedListConstructorLiteralFunc", patterns: [.cons([.list([.int(1)])], .list([.int(2)]))], when: .yes, body: .string("ok")),
        Function(name: "zip", patterns: [.list([.list([]), .list([])])], when: .yes, body: .list([])),
        Function(name: "zip",
                    patterns: [.list([
                        .cons([.name("x")], .name("xs")),
                        .cons([.name("y")], .name("ys"))
                        ])],
                    when: .yes,
                    body: .call("+", [
                        .list([.list([.name("x"), .name("y")])]),
                        .call("zip", [.list([.name("xs"), .name("ys")])])
                        ])),
        Function(name: "variableFunc", patterns: [.name("x")], when: .yes, body: .name("x")),
        Function(name: "repeatedVariableFunc", patterns: [.name("x"), .name("x")], when: .yes, body: .name("x")),
        Function(name: "repeatedNestedVariableFunc",
                    patterns: [.cons([.name("x")], .ignore),
                               .cons([.name("x")], .ignore)],
                    when: .yes,
                    body: .name("x")),
    ]

    var context = rootContext

    override func setUp() {
        context = extend(context: rootContext, with: try! declareSubfunctions(functions))
    }

    func test_literal_wrongType_fails() {
        let call = Expression.call("numberLiteralFunc", [.string("two")])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_literal_arityMismatch_fails() {
        let call = Expression.call("numberLiteralFunc", [.int(2), .int(3)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_ignoreVariable_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("ignoreVariableFunc", [.int(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.string("ok"), actual)
        }
    }

    func test_boolLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("booleanLiteralFunc", [.no])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.string("ok"), actual)
        }
    }

    func test_boolLiteral_noMatch_fails() {
        let call = Expression.call("booleanLiteralFunc", [.yes])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_numberLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("numberLiteralFunc", [.int(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.string("ok"), actual)
        }
    }

    func test_numberLiteral_noMatch_fails() {
        let call = Expression.call("numberLiteralFunc", [.int(3)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("listLiteralFunc", [.list([.int(1), .int(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.string("ok"), actual)
        }
    }

    func test_listLiteral_noMatch_fails() {
        let call = Expression.call("listLiteralFunc", [.list([.int(1)])])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listConstructorLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("listConstructorLiteralFunc", [.list([.int(1), .int(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.string("ok"), actual)
        }
    }

    func test_nestedListConstructorLiteral_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("nestedListConstructorLiteralFunc", [.list([.list([.int(1)]), .int(2)])])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.string("ok"), actual)
        }
    }

    func test_nestedList_match_evaluates() {
        assertNoThrow {

            let call = Expression.call("zip", [
                .list([
                    .list([.int(1), .int(2)]),
                    .list([.int(3), .int(4)])
                    ])
                ])
            let actual = try call.evaluate(context: context)
            let expected = Expression.list([
                .list([.int(1), .int(3)]),
                .list([.int(2), .int(4)])
                ])
            XCTAssertEqual(expected, actual)
        }
    }

    func test_nestedList_argumentNotAList_fails() {
        let call = Expression.call("zip", [.int(1)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listConstructorLiteral_insufficentItemsToMatch_evaluates() {
        let call = Expression.call("listConstructorVariableFunc", [.list([.int(1)])])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_listConstructorLiteral_argumentNotAList_evaluates() {
        let call = Expression.call("listConstructorLiteralFunc", [.int(1)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_variable_match_evaluates() {
        assertNoThrow {
            let call = Expression.call("variableFunc", [.int(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.int(2), actual)
        }
    }

    func test_repeatedVariable_unequal_throws() {
        let call = Expression.call("repeatedVariableFunc", [.int(2), .int(3)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_repeatedVariable_equal_binds() {
        assertNoThrow {
            let call = Expression.call("repeatedVariableFunc", [.int(2), .int(2)])
            XCTAssertEqual(.int(2), try call.evaluate(context: context))
        }
    }

    func test_repeatedVariable_float_throws() {
        let call = Expression.call("repeatedVariableFunc", [.float(4.1), .float(4.1)])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_repeatedVariable_shadowsExistingVariable_overridesButSucceeds() {
        assertNoThrow {

            var context: Context = ["x": .int(5)]

            let foo = Function(name: "foo", patterns: [.name("x"), .name("x")], when: .yes, body: .name("x"))

            context = try declareSubfunctions([.function(foo)], in: context)
            
            let call = Expression.call("foo", [.int(2), .int(2)])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(.int(2), actual)
        }
    }

    func test_repeatedVariable_nested_unequal_throws() {
        let call = Expression.call("repeatedNestedVariableFunc", [
            .list([.int(5)]), .list([.int(3)])
            ])
        XCTAssertThrowsError(try call.evaluate(context: context))
    }

    func test_repeatedVariable_nested_equal_binds() {
        assertNoThrow {
            let call = Expression.call("repeatedNestedVariableFunc", [
                .list([.int(5)]), .list([.int(5)])
                ])
            XCTAssertEqual(.int(5), try call.evaluate(context: context))
        }
    }
}
