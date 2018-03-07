import XCTest
import Song

class ParserTests: XCTestCase {

    func test_booleans() {
        "Yes".becomes(.bool(true))
        "No".becomes(.bool(false))
        " Yes ".becomes(.bool(true))
    }

    func test_integers() {
        "99".becomes(.integerValue(99))
        "+99".becomes(.integerValue(99))
        "-21".becomes(.call("-", [.integerValue(21)]))
        "0".becomes(.integerValue(0))
        "-0".becomes(.call("-", [.integerValue(0)]))
        " 99 ".becomes(.integerValue(99))

        "9d".fails()
    }

    func test_floats() {
        "0.1".becomes(.floatValue(0.1))
        "+0.1".becomes(.floatValue(0.1))
        "-9.1".becomes(.call("-", [.floatValue(9.1)]))
        "0.001".becomes(.floatValue(0.001))
        " 0.001 ".becomes(.floatValue(0.001))

        ".1".fails()
    }

    func test_characters() {
        "'A'".becomes(.char("A"))
        "' '".becomes(.char(" "))
        "'\\''".becomes(.char("'"))
        "'\"'".becomes(.char("\""))
        "'\\\\'".becomes(.char("\\"))
        "'AB'".fails()
        "'''".fails()
    }

    func test_strings() {
        "\"\"".becomes(.stringValue(""))
        "\"'\"".becomes(.stringValue("'"))
        "\"hello world\"".becomes(.stringValue("hello world"))
        "\"\\\"Hi,\\\" I said\"".becomes(.stringValue("\"Hi,\" I said"))
        "\"a\\\\backslash\"".becomes(.stringValue("a\\backslash"))
        " \"hello world\" ".becomes(.stringValue("hello world"))
    }

    func test_lists() {
        "[]".becomes(.list([]))
        " [] ".becomes(.list([]))
        "[1,No]".becomes(.list([.integerValue(1), .bool(false)]))
        "[ 1 , Yes , \"hi\" ]".becomes(.list([.integerValue(1), .bool(true), .stringValue("hi")]))
        "[[1,2],[No,4], [], \"hi\"]".becomes(.list([
            .list([.integerValue(1), .integerValue(2)]),
            .list([.bool(false), .integerValue(4)]),
            .list([]),
            .stringValue("hi")
            ]))
"""
[
  1 ,

  No
]
""".becomes(.list([.integerValue(1), .bool(false)]))
    }

    func test_listConstructors() {
        "[x|xs]".becomes(.listCons([.variable("x")], .variable("xs")))
        "[x,y|xs]".becomes(.listCons([.variable("x"), .variable("y")], .variable("xs")))
        "[ 1 , x | xs ]".becomes(.listCons([.integerValue(1), .variable("x")], .variable("xs")))
        "[Yes|2]".becomes(.listCons([.bool(true)], .integerValue(2)))
        "[ f(x) | g(x) ]".becomes(.listCons([.call("f", [.variable("x")])],
                                                   .call("g", [.variable("x")])))
        "[1,2|[3,4|[5,6]]]".becomes(.listCons(
            [.integerValue(1), .integerValue(2)],
            .listCons(
                [.integerValue(3), .integerValue(4)],
                .list([.integerValue(5), .integerValue(6)])
            )))
"""
[
 x, y
 |
 xs
]
""".becomes(.listCons([.variable("x"), .variable("y")], .variable("xs")))

        "[|xs]".fails()
        "[x|]".fails()
    }

    func test_expressions() {
        "1*2".becomes(.call("*", [.integerValue(1), .integerValue(2)]))
        "1*2*3".becomes(.call("*", [
            .call("*", [.integerValue(1), .integerValue(2)]),
            .integerValue(3)]))
        "1+2*3/4-5".becomes(
            .call("-", [
                .call("+", [
                    .integerValue(1),
                    .call("/", [
                        .call("*", [
                            .integerValue(2),
                            .integerValue(3)
                            ])
                        , .integerValue(4)]),
                    ]),
                .integerValue(5)
                ]))
        "12 Div 5".becomes(.call("Div", [.integerValue(12), .integerValue(5)]))
        "12 Mod 5".becomes(.call("Mod", [.integerValue(12), .integerValue(5)]))
        "x Eq 5".becomes(.call("Eq", [.variable("x"), .integerValue(5)]))
        "Do 2, 5 < 7 End And Do Yes End".becomes(.call("And", [.scope([.integerValue(2), .call("<", [.integerValue(5), .integerValue(7)])]), .scope([.bool(true)])]))

        "12 Div5".fails()
        "12 Mod5".fails()
        "12Div 5".fails()
        "12Mod 5".fails()
    }

    func test_equality() {
        "4 Neq 8".becomes(.call("Neq", [.integerValue(4), .integerValue(8)]))
        "\"hi\" Neq \"ho\"".becomes(.call("Neq", [.stringValue("hi"), .stringValue("ho")]))
        "[4] Neq [7]".becomes(.call("Neq", [.list([.integerValue(4)]), .list([.integerValue(7)])]))

        "4 Eq 3".becomes(.call("Eq", [.integerValue(4), .integerValue(3)]))
        "4 Eq [7]".becomes(.call("Eq", [.integerValue(4), .list([.integerValue(7)])]))
        "4 Eq \"hi\"".becomes(.call("Eq", [.integerValue(4), .stringValue("hi")]))

        "\"hi\" Eq \"ho\"".becomes(.call("Eq", [.stringValue("hi"), .stringValue("ho")]))
        "\"hi\" Eq [7]".becomes(.call("Eq", [.stringValue("hi"), .list([.integerValue(7)])]))
        "\"hi\" Eq 3".becomes(.call("Eq", [.stringValue("hi"), .integerValue(3)]))

        "[7] Eq [7]".becomes(.call("Eq", [.list([.integerValue(7)]), .list([.integerValue(7)])]))
        "[7] Eq 3".becomes(.call("Eq", [.list([.integerValue(7)]), .integerValue(3)]))
        "[7] Eq \"hi\"".becomes(.call("Eq", [.list([.integerValue(7)]), .stringValue("hi")]))
    }

    func test_wrappedExpressions() {
        "1+2*3".becomes(.call("+", [
            .integerValue(1),
            .call("*", [.integerValue(2), .integerValue(3)])
            ]))
        "(1+2)*3".becomes(.call("*", [
            .call("+", [.integerValue(1), .integerValue(2)]),
            .integerValue(3)
            ]))
        "(5-+2)*-3".becomes(.call("*", [
            .call("-", [.integerValue(5), .integerValue(2)]),
            .call("-", [.integerValue(3)])
            ]))
    }

    func test_variables() {
        "_".becomes(.ignore)
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
            .subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .integerValue(5)))
        )
        "foo(a) = a".becomes(
            .subfunction(Subfunction(name: "foo", patterns: [.variable("a")], when: .bool(true), body: .variable("a")))
        )
"""
foo(a,
    b) = a
""".becomes(.subfunction(Subfunction(name: "foo", patterns: [.variable("a"), .variable("b")], when: .bool(true), body: .variable("a"))))
"""
foo(
  a,
  b
) = a
""".becomes(.subfunction(Subfunction(name: "foo", patterns: [.variable("a"), .variable("b")], when: .bool(true), body: .variable("a"))))
        "a.foo = a".becomes(
            .subfunction(Subfunction(name: "foo", patterns: [.variable("a")], when: .bool(true), body: .variable("a")))
        )
        "a.foo When a < 50 = a".becomes(
            .subfunction(Subfunction(name: "foo",
                                     patterns: [.variable("a")],
                                     when: .call("<", [.variable("a"), .integerValue(50)]),
                                     body: .variable("a")))
        )
        "a.foo() When a < 50 = a".becomes(
            .subfunction(Subfunction(name: "foo",
                                     patterns: [.variable("a")],
                                     when: .call("<", [.variable("a"), .integerValue(50)]),
                                     body: .variable("a")))
        )
        "a.plus(b) = a + b".becomes(
            .subfunction(Subfunction(name: "plus", patterns: [.variable("a"), .variable("b")], when: .bool(true), body: .call("+", [.variable("a"), .variable("b")])))
        )
        "[x|xs].map(f) = [f(x)|xs.map(f)]".becomes(
            .subfunction(Subfunction(name: "map",
                                     patterns: [.listCons([.variable("x")], .variable("xs")), .variable("f")],
                                     when: .bool(true),
                                     body: .listCons([.call("f", [.variable("x")])],
                                                            .call("map", [.variable("xs"), .variable("f")]))))
        )
"""
a.foo =
 5
""".becomes(.subfunction(Subfunction(name: "foo", patterns: [.variable("a")], when: .bool(true), body: .integerValue(5))))
"""
foo() =
5
""".becomes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .integerValue(5))))
("foo() =" + " " + "\n5").becomes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .integerValue(5))))
"""
foo() =
  5
""".becomes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .integerValue(5))))
"""
foo() = Do
  5
End
""".becomes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .scope([.integerValue(5)]))))
"""
foo() =
Do
  5
End
""".becomes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .scope([.integerValue(5)]))))
"""
foo() = Do 5
End
""".becomes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .scope([.integerValue(5)]))))
"""
foo() = Do 5 End
""".becomes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .scope([.integerValue(5)]))))
    }

    func test_constants() {
        "x = 5".becomes(.assign(variable: .variable("x"), value: .integerValue(5)))
        "x=5".becomes(.assign(variable: .variable("x"), value: .integerValue(5)))
        "_ = 5".becomes(.assign(variable: .ignore, value: .integerValue(5)))
        "double = |x| x * 2".becomes(.assign(variable: .variable("double"), value:
            .subfunction(Subfunction(name: nil,
                                     patterns: [.variable("x")],
                                     when: .bool(true),
                                     body: .call("*", [.variable("x"), .integerValue(2)])))))

        "2 = 5".fails()
    }

    func test_lambdas() {
        "|x| x".becomes(.subfunction(Subfunction(name: nil, patterns: [.variable("x")], when: .bool(true), body: .variable("x"))))
        "| x , y | x".becomes(.subfunction(Subfunction(name: nil, patterns: [.variable("x"), .variable("y")], when: .bool(true), body: .variable("x"))))
"""
 |
 x
 ,
 y
 |
 x
""".becomes(.subfunction(Subfunction(name: nil, patterns: [.variable("x"), .variable("y")], when: .bool(true), body: .variable("x"))))
        "|[x|xs], y| x".becomes(.subfunction(Subfunction(name: nil, patterns: [.listCons([.variable("x")], .variable("xs")), .variable("y")], when: .bool(true), body: .variable("x"))))
        "|_| 5".becomes(.subfunction(Subfunction(name: nil, patterns: [.ignore], when: .bool(true), body: .integerValue(5))))
        "|| 5".becomes(.subfunction(Subfunction(name: nil, patterns: [], when: .bool(true), body: .integerValue(5))))
    }

    func test_negations() {
        "+5".becomes(.integerValue(5))
        "-5".becomes(.call("-", [.integerValue(5)]))
        "-x".becomes(.call("-", [.variable("x")]))
        "-foo(1)".becomes(.call("-", [.call("foo", [.integerValue(1)])]))
        "--x".becomes(.call("-", [.call("-", [.variable("x")])]))
        "Not x".becomes(.call("Not", [.variable("x")]))
        "Not Not x".becomes(.call("Not", [.call("Not", [.variable("x")])]))
        "9--5".becomes(.call("-", [.integerValue(9), .call("-", [.integerValue(5)])]))
    }

    func test_calls() {
        "foo()".becomes(.call("foo", []))
        "foo(a)".becomes(.call("foo", [.variable("a")]))
        "foo(4)".becomes(.call("foo", [.integerValue(4)]))
        "4.foo".becomes(.call("foo", [.integerValue(4)]))
        "4.foo()".becomes(.call("foo", [.integerValue(4)]))
        "foo(x, y)".becomes(.call("foo", [.variable("x"), .variable("y")]))
        "foo(x,y)".becomes(.call("foo", [.variable("x"), .variable("y")]))
        "foo( x , y )".becomes(.call("foo", [.variable("x"), .variable("y")]))
"""
foo(
  x
 ,
  y
 )
""".becomes(.call("foo", [.variable("x"), .variable("y")]))
    }

    func test_callChains() {
        "3.foo.bar".becomes(.call("bar", [.call("foo", [.integerValue(3)])]))
        "3.foo().bar".becomes(.call("bar", [.call("foo", [.integerValue(3)])]))
        "3.foo.bar()".becomes(.call("bar", [.call("foo", [.integerValue(3)])]))
        "3.foo().bar()".becomes(.call("bar", [.call("foo", [.integerValue(3)])]))
        "3.foo(5).bar()".becomes(.call("bar", [.call("foo", [.integerValue(3), .integerValue(5)])]))
        "3.foo(5).bar".becomes(.call("bar", [.call("foo", [.integerValue(3), .integerValue(5)])]))
        "3.foo().bar(5)".becomes(.call("bar", [.call("foo", [.integerValue(3)]), .integerValue(5)]))
        "3.foo.bar(5)".becomes(.call("bar", [.call("foo", [.integerValue(3)]), .integerValue(5)]))
        "3.foo(9).bar(5)".becomes(.call("bar", [.call("foo", [.integerValue(3), .integerValue(9)]), .integerValue(5)]))
        "foo().bar".becomes(.call("bar", [.call("foo", [])]))
        "foo().bar()".becomes(.call("bar", [.call("foo", [])]))
        "foo(3).bar()".becomes(.call("bar", [.call("foo", [.integerValue(3)])]))
    }

    func test_nestedCalls() {

        "foo(bar())".becomes(.call("foo", [.call("bar", [])]))
        "foo(bar(4))".becomes(.call("foo", [.call("bar", [.integerValue(4)])]))
        "foo(1, bar(4))".becomes(.call("foo", [
            .integerValue(1),
            .call("bar", [.integerValue(4)])]))
        "1.foo(bar(4))".becomes(.call("foo", [
            .integerValue(1),
            .call("bar", [.integerValue(4)])]))

        "foo( x( a , b ) , y( c , d) )".becomes(
            .call("foo", [
                .call("x", [.variable("a"), .variable("b")]),
                .call("y", [.variable("c"), .variable("d")])
                ]))

        "3.foo(5.bar(6.foo(9)).foo()).bar(foo(3).bar)".becomes(
            .call("bar", [
                .call("foo", [
                    .integerValue(3),
                    .call("foo", [
                        .call("bar", [
                            .integerValue(5),
                            .call("foo", [
                                .integerValue(6),
                                .integerValue(9)
                                ])
                            ])
                        ])
                    ]),
                .call("bar", [
                    .call("foo", [.integerValue(3)])
                    ])
                ]))
    }

    func test_scopes() {
        "Do _ End".becomes(.scope([.ignore]))
        "Do 1 End".becomes(.scope([.integerValue(1)]))
        "Do 1, End".becomes(.scope([.integerValue(1)]))
        "Do 1, x End".becomes(.scope([.integerValue(1), .variable("x")]))
        "Do 1 , x End".becomes(.scope([.integerValue(1), .variable("x")]))
        "Do 1, x, End".becomes(.scope([.integerValue(1), .variable("x")]))
        "Do x = 5, x End".becomes(.scope([.assign(variable: .variable("x"), value: .integerValue(5)), .variable("x")]))
        "Do |x| x End".becomes(.scope([.subfunction(Subfunction(name: nil, patterns: [.variable("x")], when: .bool(true), body: .variable("x")))]))
        "Do x.inc = x+1, 7.inc End".becomes(.scope([
            .subfunction(Subfunction(name: "inc", patterns: [.variable("x")], when: .bool(true), body: .call("+", [.variable("x"), .integerValue(1)]))),
            .call("inc", [.integerValue(7)])]))
        "Do 1, Do Do 2, 3 End, 4, End, End".becomes(.scope([.integerValue(1), .scope([.scope([.integerValue(2), .integerValue(3)]), .integerValue(4)])]))

"""
Do 1
2
3 End
""".becomes(.scope([.integerValue(1), .integerValue(2), .integerValue(3)]))
"""
Do
  1
  2
  3
End
""".becomes(.scope([.integerValue(1), .integerValue(2), .integerValue(3)]))
"""
Do 1
2,3 End
""".becomes(.scope([.integerValue(1), .integerValue(2), .integerValue(3)]))
"""
Do
  1
  2
  3
End
""".becomes(.scope([.integerValue(1), .integerValue(2), .integerValue(3)]))
"""
Do
  1 , 2
  3
End
""".becomes(.scope([.integerValue(1), .integerValue(2), .integerValue(3)]))
"""
Do
  1,
  2,
  3
End
""".becomes(.scope([.integerValue(1), .integerValue(2), .integerValue(3)]))
"""
Do
  1,
  2,
  3,
End
""".becomes(.scope([.integerValue(1), .integerValue(2), .integerValue(3)]))

        "DoEnd".fails()
        "Do End".fails()
        "Do , End".fails()
        "Do,End".fails()
        "Do1End".fails()
    }

    func test_unusualFunctionCalls() {
        "(1 < 10).negate".becomes(.call("negate", [.call("<", [.integerValue(1), .integerValue(10)])]))
        "(Do 5, 8 End).inc".becomes(.call("inc", [.scope([.integerValue(5), .integerValue(8)])]))
        "(Do |x| x+1 End)(5)".becomes(.callAnon(.scope([.subfunction(Subfunction(name: nil, patterns: [.variable("x")], when: .bool(true), body: .call("+", [.variable("x"), .integerValue(1)])))]), [.integerValue(5)]))
        "(inc(1)).inc".becomes(.call("inc", [.call("inc", [.integerValue(1)])]))
        "(x)()".becomes(.callAnon(.variable("x"), []))
        "5.lessThan()(4)".becomes(.callAnon(.call("lessThan", [.integerValue(5)]), [.integerValue(4)]))
        "(5.lessThan())(4)".becomes(.callAnon(.call("lessThan", [.integerValue(5)]), [.integerValue(4)]))
        "(5.lessThan)(4)".becomes(.callAnon(.call("lessThan", [.integerValue(5)]), [.integerValue(4)]))
        "lessThan(5)(4)".becomes(.callAnon(.call("lessThan", [.integerValue(5)]), [.integerValue(4)]))
        "(|x| x+1)(4)".becomes(
            .callAnon(
                .subfunction(Subfunction(name: nil,
                                                  patterns: [.variable("x")],
                                                  when: .bool(true),
                                                  body: .call("+", [.variable("x"), .integerValue(1)])
                )),
                [.integerValue(4)]))
        "4.(|x| x+1)".becomes(
            .callAnon(
                .subfunction(Subfunction(name: nil,
                                                  patterns: [.variable("x")],
                                                  when: .bool(true),
                                                  body: .call("+", [.variable("x"), .integerValue(1)])
                )),
                [.integerValue(4)]))
        "4.(|x| x+1)()".becomes(
            .callAnon(
                .callAnon(
                    .subfunction(Subfunction(name: nil,
                                                      patterns: [.variable("x")],
                                                      when: .bool(true),
                                                      body: .call("+", [.variable("x"), .integerValue(1)])
                    )),
                    [.integerValue(4)]
                ), []))
    }
}
