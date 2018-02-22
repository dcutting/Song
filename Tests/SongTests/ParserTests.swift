import XCTest
import Song

class ParserTests: XCTestCase {

    func test_booleans() {
        "yes".becomes(.booleanValue(true))
        "no".becomes(.booleanValue(false))
    }

    func test_integers() {
        "99".becomes(.integerValue(99))
        "-21".becomes(.integerValue(-21))
        "0".becomes(.integerValue(0))
        "-0".becomes(.integerValue(0))

        "9d".fails()
    }

    func test_floats() {
        "0.1".becomes(.floatValue(0.1))
        "-9.1".becomes(.floatValue(-9.1))
        "0.001".becomes(.floatValue(0.001))

        ".1".fails()
    }

    func test_strings() {
        "\"hello world\"".becomes(.stringValue("hello world"))
        "\"\\\"Hi,\\\" I said\"".becomes(.stringValue("\"Hi,\" I said"))
        "\"a\\\\backslash\"".becomes(.stringValue("a\\backslash"))
    }

    func test_lists() {
        "[]".becomes(.list([]))
        "[1,no]".becomes(.list([.integerValue(1), .booleanValue(false)]))
        "[ 1 , yes , \"hi\" ]".becomes(.list([.integerValue(1), .booleanValue(true), .stringValue("hi")]))
        "[[1,2],[no,4], [], \"hi\"]".becomes(.list([
            .list([.integerValue(1), .integerValue(2)]),
            .list([.booleanValue(false), .integerValue(4)]),
            .list([]),
            .stringValue("hi")
            ]))
    }

    func test_listConstructors() {
        "[x|xs]".becomes(.listConstructor([.variable("x")], .variable("xs")))
        "[x,y|xs]".becomes(.listConstructor([.variable("x"), .variable("y")], .variable("xs")))
        "[ 1 , x | xs ]".becomes(.listConstructor([.integerValue(1), .variable("x")], .variable("xs")))
        "[yes|2]".becomes(.listConstructor([.booleanValue(true)], .integerValue(2)))
        "[ f(x) | g(x) ]".becomes(.listConstructor([.call(name: "f", arguments: [.variable("x")])],
                                                   .call(name: "g", arguments: [.variable("x")])))
        "[1,2|[3,4|[5,6]]]".becomes(.listConstructor(
            [.integerValue(1), .integerValue(2)],
            .listConstructor(
                [.integerValue(3), .integerValue(4)],
                .list([.integerValue(5), .integerValue(6)])
            )))

        "[|xs]".fails()
        "[x|]".fails()
    }

    func test_expressions() {
        "1*2".becomes(.call(name: "*", arguments: [.integerValue(1), .integerValue(2)]))
        "1*2*3".becomes(.call(name: "*", arguments: [
            .call(name: "*", arguments: [.integerValue(1), .integerValue(2)]),
            .integerValue(3)]))
        "1+2*3/4-5".becomes(
            .call(name: "-", arguments: [
                .call(name: "+", arguments: [
                    .integerValue(1),
                    .call(name: "/", arguments: [
                        .call(name: "*", arguments: [
                            .integerValue(2),
                            .integerValue(3)
                            ])
                        , .integerValue(4)]),
                    ]),
                .integerValue(5)
                ]))
        "12 div 5".becomes(.call(name: "div", arguments: [.integerValue(12), .integerValue(5)]))
        "12 mod 5".becomes(.call(name: "mod", arguments: [.integerValue(12), .integerValue(5)]))

        "12 div5".fails()
        "12 mod5".fails()
        "12div 5".fails()
        "12mod 5".fails()
    }

    func test_wrappedExpressions() {
        "1+2*3".becomes(.call(name: "+", arguments: [
            .integerValue(1),
            .call(name: "*", arguments: [.integerValue(2), .integerValue(3)])
            ]))
        "(1+2)*3".becomes(.call(name: "*", arguments: [
            .call(name: "+", arguments: [.integerValue(1), .integerValue(2)]),
            .integerValue(3)
            ]))
    }

    func test_variables() {
        "_".becomes(.anyVariable)
        "x".becomes(.variable("x"))
        "_x".becomes(.variable("_x"))
        "_private".becomes(.variable("_private"))
        "goodName".becomes(.variable("goodName"))
        "good_name".becomes(.variable("good_name"))
        "goodName99".becomes(.variable("goodName99"))
        "good_".becomes(.variable("good_"))

        "GoodName".fails()
        "9bottles".fails()
    }

    func test_subfunctions() {
        "foo() = 5".becomes(
            .subfunction(Subfunction(name: "foo", patterns: [], when: .booleanValue(true), body: .integerValue(5)))
        )
        "foo(a) = a".becomes(
            .subfunction(Subfunction(name: "foo", patterns: [.variable("a")], when: .booleanValue(true), body: .variable("a")))
        )
        "a.foo = a".becomes(
            .subfunction(Subfunction(name: "foo", patterns: [.variable("a")], when: .booleanValue(true), body: .variable("a")))
        )
        "a.foo when a < 50 = a".becomes(
            .subfunction(Subfunction(name: "foo",
                                     patterns: [.variable("a")],
                                     when: .call(name: "<", arguments: [.variable("a"), .integerValue(50)]),
                                     body: .variable("a")))
        )
        "a.foo() when a < 50 = a".becomes(
            .subfunction(Subfunction(name: "foo",
                                     patterns: [.variable("a")],
                                     when: .call(name: "<", arguments: [.variable("a"), .integerValue(50)]),
                                     body: .variable("a")))
        )
        "a.plus(b) = a + b".becomes(
            .subfunction(Subfunction(name: "plus", patterns: [.variable("a"), .variable("b")], when: .booleanValue(true), body: .call(name: "+", arguments: [.variable("a"), .variable("b")])))
        )
        "[x|xs].map(f) = [f(x)|xs.map(f)]".becomes(
            .subfunction(Subfunction(name: "map",
                                     patterns: [.listConstructor([.variable("x")], .variable("xs")), .variable("f")],
                                     when: .booleanValue(true),
                                     body: .listConstructor([.call(name: "f", arguments: [.variable("x")])],
                                                            .call(name: "map", arguments: [.variable("xs"), .variable("f")]))))
        )
    }

    func test_constants() {
        "let x = 5".becomes(.constant(variable: .variable("x"), value: .integerValue(5)))
        "let double = |x| x * 2".becomes(.constant(variable: .variable("double"), value:
            .subfunction(Subfunction(name: nil,
                                     patterns: [.variable("x")],
                                     when: .booleanValue(true),
                                     body: .call(name: "*", arguments: [.variable("x"), .integerValue(2)])))))
    }

    func test_calls() {
        "foo()".becomes(.call(name: "foo", arguments: []))
        "foo(a)".becomes(.call(name: "foo", arguments: [.variable("a")]))
        "foo(4)".becomes(.call(name: "foo", arguments: [.integerValue(4)]))
        "4.foo".becomes(.call(name: "foo", arguments: [.integerValue(4)]))
        "4.foo()".becomes(.call(name: "foo", arguments: [.integerValue(4)]))
        "foo(x, y)".becomes(.call(name: "foo", arguments: [.variable("x"), .variable("y")]))
        "foo(x,y)".becomes(.call(name: "foo", arguments: [.variable("x"), .variable("y")]))
        "foo( x , y )".becomes(.call(name: "foo", arguments: [.variable("x"), .variable("y")]))
    }

    func test_callChains() {
        "3.foo.bar".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [.integerValue(3)])]))
        "3.foo().bar".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [.integerValue(3)])]))
        "3.foo.bar()".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [.integerValue(3)])]))
        "3.foo().bar()".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [.integerValue(3)])]))
        "3.foo(5).bar()".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [.integerValue(3), .integerValue(5)])]))
        "3.foo(5).bar".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [.integerValue(3), .integerValue(5)])]))
        "3.foo().bar(5)".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [.integerValue(3)]), .integerValue(5)]))
        "3.foo.bar(5)".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [.integerValue(3)]), .integerValue(5)]))
        "3.foo(9).bar(5)".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [.integerValue(3), .integerValue(9)]), .integerValue(5)]))
        "foo().bar".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [])]))
        "foo().bar()".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [])]))
        "foo(3).bar()".becomes(.call(name: "bar", arguments: [.call(name: "foo", arguments: [.integerValue(3)])]))
    }

    func test_nestedCalls() {

        "foo(bar())".becomes(.call(name: "foo", arguments: [.call(name: "bar", arguments: [])]))
        "foo(bar(4))".becomes(.call(name: "foo", arguments: [.call(name: "bar", arguments: [.integerValue(4)])]))
        "foo(1, bar(4))".becomes(.call(name: "foo", arguments: [
            .integerValue(1),
            .call(name: "bar", arguments: [.integerValue(4)])]))
        "1.foo(bar(4))".becomes(.call(name: "foo", arguments: [
            .integerValue(1),
            .call(name: "bar", arguments: [.integerValue(4)])]))

        "foo( x( a , b ) , y( c , d) )".becomes(
            .call(name: "foo", arguments: [
                .call(name: "x", arguments: [.variable("a"), .variable("b")]),
                .call(name: "y", arguments: [.variable("c"), .variable("d")])
                ]))

        "3.foo(5.bar(6.foo(9)).foo()).bar(foo(3).bar)".becomes(
            .call(name: "bar", arguments: [
                .call(name: "foo", arguments: [
                    .integerValue(3),
                    .call(name: "foo", arguments: [
                        .call(name: "bar", arguments: [
                            .integerValue(5),
                            .call(name: "foo", arguments: [
                                .integerValue(6),
                                .integerValue(9)
                                ])
                            ])
                        ])
                    ]),
                .call(name: "bar", arguments: [
                    .call(name: "foo", arguments: [.integerValue(3)])
                    ])
                ]))
    }
}
