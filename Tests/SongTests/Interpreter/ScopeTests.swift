import XCTest
import SongLang

class ScopeTests: XCTestCase {

    func test_description() {
        let scope = Expression.scope([.int(1), .int(2)])
        XCTAssertEqual("scope (1, 2)", "\(scope)")
    }

    func test_noStatements_throws() {
        XCTAssertThrowsError(try Expression.scope([]).evaluate())
    }

    func test_oneLiteralStatement_returnsLiteral() {
        assertNoThrow {
            let scope = Expression.scope([.int(9)])
            XCTAssertEqual(Expression.int(9), try scope.evaluate())
        }
    }

    func test_twoLiteralStatement_returnsLastLiteral() {
        assertNoThrow {
            let scope = Expression.scope([.int(9), .int(5)])
            XCTAssertEqual(Expression.int(5), try scope.evaluate())
        }
    }

    func test_oneCompoundStatement_returnsEvaluatedStatement() {
        assertNoThrow {
            let scope = Expression.scope([.call("+", [.int(9), .int(3)])])
            XCTAssertEqual(Expression.int(12), try scope.evaluate())
        }
    }

    func test_capturesCallingContext() {
        assertNoThrow {
            let context: Context = ["x": .int(9)]
            let scope = Expression.scope([.name("x")])
            XCTAssertEqual(Expression.int(9), try scope.evaluate(context: context))
        }
    }

    func test_localConstsOverrideCallingContext() {
        assertNoThrow {
            let context: Context = ["x": .int(9)]
            let scope = Expression.scope([
                .assign(variable: .name("x"), value: .int(5)),
                .name("x")
                ])
            XCTAssertEqual(Expression.int(5), try scope.evaluate(context: context))
        }
    }

    func test_multipleLocalConstsOverrideEachOther() {
        assertNoThrow {
            let context: Context = ["x": .int(9)]
            let scope = Expression.scope([
                .assign(variable: .name("x"), value: .int(5)),
                .assign(variable: .name("x"), value: .int(2)),
                .assign(variable: .name("x"), value: .int(99)),
                .name("x")
                ])
            XCTAssertEqual(Expression.int(99), try scope.evaluate(context: context))
        }
    }

    func test_localFunctionsCanMatch() {
        assertNoThrow {
            let scope = Expression.scope([
                makeFoo(.name("x"), .name("x")),
                callFoo(.int(9))
                ])
            XCTAssertEqual(Expression.int(9), try scope.evaluate())
        }
    }

    func test_matchesAgainstLocalFunctionsLexicallyThenOuterFunctionsLexically() {

        var context = try! declareSubfunctions([
            makeFoo(.int(9), .string("N I N E")),
            makeFoo(.name("x"), .name("x"))
        ])
        context = extend(context: rootContext, with: context)

        let inScope = [
            makeFoo(.int(9), .string("nine")),
            makeFoo(.name("x"),
                    when: .call(">", [.name("x"), .int(100)]),
                    .string("BIG")),
            makeFoo(.int(2), .string("two"))
        ]

        assertNoThrow {
            let scope = Expression.scope(inScope + [callFoo(.int(9))])
            XCTAssertEqual(Expression.string("nine"), try scope.evaluate(context: context))
        }

        let scope = Expression.scope(inScope + [callFoo(.int(5))])
        XCTAssertThrowsError(try scope.evaluate(context: context))

        assertNoThrow {
            let scope = Expression.scope(inScope + [callFoo(.int(500))])
            XCTAssertEqual(Expression.string("BIG"), try scope.evaluate(context: context))
        }
        assertNoThrow {
            let scope = Expression.scope(inScope + [callFoo(.int(2))])
            XCTAssertEqual(Expression.string("two"), try scope.evaluate(context: context))
        }
    }

    private func makeFoo(_ pattern: Expression,
                         when: Expression = .yes,
                         _ body: Expression) -> Expression {
        return .function(Function(name: "foo", patterns: [pattern], when: when, body: body))
    }

    private func callFoo(_ argument: Expression) -> Expression {
        return .call("foo", [argument])
    }
}
