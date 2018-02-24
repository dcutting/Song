import XCTest
import Song

class ScopeTests: XCTestCase {

    func test_description() {
        let scope = Expression.scope([.integerValue(1), .integerValue(2)])
        XCTAssertEqual("scope (1, 2)", "\(scope)")
    }

    func test_noStatements_throws() {
        XCTAssertThrowsError(try Expression.scope([]).evaluate())
    }

    func test_oneLiteralStatement_returnsLiteral() {
        assertNoThrow {
            let scope = Expression.scope([.integerValue(9)])
            XCTAssertEqual(Expression.integerValue(9), try scope.evaluate())
        }
    }

    func test_twoLiteralStatement_returnsLastLiteral() {
        assertNoThrow {
            let scope = Expression.scope([.integerValue(9), .integerValue(5)])
            XCTAssertEqual(Expression.integerValue(5), try scope.evaluate())
        }
    }

    func test_oneCompoundStatement_returnsEvaluatedStatement() {
        assertNoThrow {
            let scope = Expression.scope([.call(name: "+", arguments: [.integerValue(9), .integerValue(3)])])
            XCTAssertEqual(Expression.integerValue(12), try scope.evaluate())
        }
    }

    func test_capturesCallingContext() {
        assertNoThrow {
            let context: Context = ["x": [.integerValue(9)]]
            let scope = Expression.scope([.variable("x")])
            XCTAssertEqual(Expression.integerValue(9), try scope.evaluate(context: context))
        }
    }

    func test_localConstsOverrideCallingContext() {
        assertNoThrow {
            let context: Context = ["x": [.integerValue(9)]]
            let scope = Expression.scope([
                .constant(variable: .variable("x"), value: .integerValue(5)),
                .variable("x")
                ])
            XCTAssertEqual(Expression.integerValue(5), try scope.evaluate(context: context))
        }
    }

    func test_multipleLocalConstsOverrideEachOther() {
        assertNoThrow {
            let context: Context = ["x": [.integerValue(9)]]
            let scope = Expression.scope([
                .constant(variable: .variable("x"), value: .integerValue(5)),
                .constant(variable: .variable("x"), value: .integerValue(2)),
                .constant(variable: .variable("x"), value: .integerValue(99)),
                .variable("x")
                ])
            XCTAssertEqual(Expression.integerValue(99), try scope.evaluate(context: context))
        }
    }

    func test_localFunctionsCanMatch() {
        assertNoThrow {
            let scope = Expression.scope([
                makeFoo(.variable("x"), .variable("x")),
                callFoo(.integerValue(9))
                ])
            XCTAssertEqual(Expression.integerValue(9), try scope.evaluate())
        }
    }

    func test_matchesAgainstLocalFunctionsLexicallyThenOuterFunctionsLexically() {

        let context: Context = [
            "foo": [
                makeFoo(.integerValue(9), .stringValue("N I N E")),
                makeFoo(.variable("x"), .variable("x"))
            ]
        ]

        let inScope = [
            makeFoo(.integerValue(9), .stringValue("nine")),
            makeFoo(.variable("x"),
                    when: .call(name: ">", arguments: [.variable("x"), .integerValue(100)]),
                    .stringValue("BIG")),
            makeFoo(.integerValue(2), .stringValue("two"))
        ]

        assertNoThrow {
            let scope = Expression.scope(inScope + [callFoo(.integerValue(9))])
            XCTAssertEqual(Expression.stringValue("nine"), try scope.evaluate(context: context))
        }
        assertNoThrow {
            let scope = Expression.scope(inScope + [callFoo(.integerValue(5))])
            XCTAssertEqual(Expression.integerValue(5), try scope.evaluate(context: context))
        }
        assertNoThrow {
            let scope = Expression.scope(inScope + [callFoo(.integerValue(500))])
            XCTAssertEqual(Expression.stringValue("BIG"), try scope.evaluate(context: context))
        }
        assertNoThrow {
            let scope = Expression.scope(inScope + [callFoo(.integerValue(2))])
            XCTAssertEqual(Expression.stringValue("two"), try scope.evaluate(context: context))
        }
    }

    private func makeFoo(_ pattern: Expression,
                         when: Expression = .booleanValue(true),
                         _ body: Expression) -> Expression {
        return .subfunction(Subfunction(name: "foo", patterns: [pattern], when: when, body: body))
    }

    private func callFoo(_ argument: Expression) -> Expression {
        return .call(name: "foo", arguments: [argument])
    }
}
