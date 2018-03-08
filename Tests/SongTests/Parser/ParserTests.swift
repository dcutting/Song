import XCTest
import Song

class ParserTests: XCTestCase {

    func test_booleans() {
        "Yes".makes(.bool(true))
        "No".makes(.bool(false))
        " Yes ".makes(.bool(true))
    }

    func test_integers() {
        "99".makes(.int(99))
        "+99".makes(.int(99))
        "-21".makes(.call("-", [.int(21)]))
        "0".makes(.int(0))
        "-0".makes(.call("-", [.int(0)]))
        " 99 ".makes(.int(99))

        "9d".fails()
    }

    func test_floats() {
        "0.1".makes(.float(0.1))
        "+0.1".makes(.float(0.1))
        "-9.1".makes(.call("-", [.float(9.1)]))
        "0.001".makes(.float(0.001))
        " 0.001 ".makes(.float(0.001))

        ".1".fails()
    }

    func test_characters() {
        "'A'".makes(.char("A"))
        "' '".makes(.char(" "))
        "'\\''".makes(.char("'"))
        "'\"'".makes(.char("\""))
        "'\\\\'".makes(.char("\\"))
        "'AB'".fails()
        "'''".fails()
    }

    func test_strings() {
        "\"\"".makes(.string(""))
        "\"'\"".makes(.string("'"))
        "\"hello world\"".makes(.string("hello world"))
        "\"\\\"Hi,\\\" I said\"".makes(.string("\"Hi,\" I said"))
        "\"a\\\\backslash\"".makes(.string("a\\backslash"))
        " \"hello world\" ".makes(.string("hello world"))
    }

    func test_lists() {
        "[]".makes(.list([]))
        " [] ".makes(.list([]))
        "[1,No]".makes(.list([.int(1), .bool(false)]))
        "[ 1 , Yes , \"hi\" ]".makes(.list([.int(1), .bool(true), .string("hi")]))
        "[[1,2],[No,4], [], \"hi\"]".makes(.list([
            .list([.int(1), .int(2)]),
            .list([.bool(false), .int(4)]),
            .list([]),
            .string("hi")
            ]))
"""
[
  1 ,

  No
]
""".makes(.list([.int(1), .bool(false)]))
    }

    func test_listConstructors() {
        "[x|xs]".makes(.listCons([.variable("x")], .variable("xs")))
        "[x,y|xs]".makes(.listCons([.variable("x"), .variable("y")], .variable("xs")))
        "[ 1 , x | xs ]".makes(.listCons([.int(1), .variable("x")], .variable("xs")))
        "[Yes|2]".makes(.listCons([.bool(true)], .int(2)))
        "[ f(x) | g(x) ]".makes(.listCons([.call("f", [.variable("x")])],
                                                   .call("g", [.variable("x")])))
        "[1,2|[3,4|[5,6]]]".makes(.listCons(
            [.int(1), .int(2)],
            .listCons(
                [.int(3), .int(4)],
                .list([.int(5), .int(6)])
            )))
"""
[
 x, y
 |
 xs
]
""".makes(.listCons([.variable("x"), .variable("y")], .variable("xs")))

        "[|xs]".fails()
        "[x|]".fails()
    }

    func test_expressions() {
        "1*2".makes(.call("*", [.int(1), .int(2)]))
        "1*2*3".makes(.call("*", [
            .call("*", [.int(1), .int(2)]),
            .int(3)]))
        "1+2*3/4-5".makes(
            .call("-", [
                .call("+", [
                    .int(1),
                    .call("/", [
                        .call("*", [
                            .int(2),
                            .int(3)
                            ])
                        , .int(4)]),
                    ]),
                .int(5)
                ]))
        "12 Div 5".makes(.call("Div", [.int(12), .int(5)]))
        "12 Mod 5".makes(.call("Mod", [.int(12), .int(5)]))
        "x Eq 5".makes(.call("Eq", [.variable("x"), .int(5)]))
        "Do 2, 5 < 7 End And Do Yes End".makes(.call("And", [.scope([.int(2), .call("<", [.int(5), .int(7)])]), .scope([.bool(true)])]))

        "12 Div5".fails()
        "12 Mod5".fails()
        "12Div 5".fails()
        "12Mod 5".fails()
    }

    func test_equality() {
        "4 Neq 8".makes(.call("Neq", [.int(4), .int(8)]))
        "\"hi\" Neq \"ho\"".makes(.call("Neq", [.string("hi"), .string("ho")]))
        "[4] Neq [7]".makes(.call("Neq", [.list([.int(4)]), .list([.int(7)])]))

        "4 Eq 3".makes(.call("Eq", [.int(4), .int(3)]))
        "4 Eq [7]".makes(.call("Eq", [.int(4), .list([.int(7)])]))
        "4 Eq \"hi\"".makes(.call("Eq", [.int(4), .string("hi")]))

        "\"hi\" Eq \"ho\"".makes(.call("Eq", [.string("hi"), .string("ho")]))
        "\"hi\" Eq [7]".makes(.call("Eq", [.string("hi"), .list([.int(7)])]))
        "\"hi\" Eq 3".makes(.call("Eq", [.string("hi"), .int(3)]))

        "[7] Eq [7]".makes(.call("Eq", [.list([.int(7)]), .list([.int(7)])]))
        "[7] Eq 3".makes(.call("Eq", [.list([.int(7)]), .int(3)]))
        "[7] Eq \"hi\"".makes(.call("Eq", [.list([.int(7)]), .string("hi")]))
    }

    func test_wrappedExpressions() {
        "1+2*3".makes(.call("+", [
            .int(1),
            .call("*", [.int(2), .int(3)])
            ]))
        "(1+2)*3".makes(.call("*", [
            .call("+", [.int(1), .int(2)]),
            .int(3)
            ]))
        "(5-+2)*-3".makes(.call("*", [
            .call("-", [.int(5), .int(2)]),
            .call("-", [.int(3)])
            ]))
    }

    func test_variables() {
        "_".makes(.ignore)
        "x".makes(.variable("x"))
        "_x".makes(.variable("_x"))
        "_private".makes(.variable("_private"))
        "goodName".makes(.variable("goodName"))
        "good_name".makes(.variable("good_name"))
        "goodName99".makes(.variable("goodName99"))
        "good_".makes(.variable("good_"))

        "GoodName".fails()
        "9bottles".fails()
    }

    func test_subfunctions() {
        "foo() = 5".makes(
            .subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .int(5)))
        )
        "foo(a) = a".makes(
            .subfunction(Subfunction(name: "foo", patterns: [.variable("a")], when: .bool(true), body: .variable("a")))
        )
"""
foo(a,
    b) = a
""".makes(.subfunction(Subfunction(name: "foo", patterns: [.variable("a"), .variable("b")], when: .bool(true), body: .variable("a"))))
"""
foo(
  a,
  b
) = a
""".makes(.subfunction(Subfunction(name: "foo", patterns: [.variable("a"), .variable("b")], when: .bool(true), body: .variable("a"))))
        "a.foo = a".makes(
            .subfunction(Subfunction(name: "foo", patterns: [.variable("a")], when: .bool(true), body: .variable("a")))
        )
        "a.foo When a < 50 = a".makes(
            .subfunction(Subfunction(name: "foo",
                                     patterns: [.variable("a")],
                                     when: .call("<", [.variable("a"), .int(50)]),
                                     body: .variable("a")))
        )
        "a.foo() When a < 50 = a".makes(
            .subfunction(Subfunction(name: "foo",
                                     patterns: [.variable("a")],
                                     when: .call("<", [.variable("a"), .int(50)]),
                                     body: .variable("a")))
        )
        "a.plus(b) = a + b".makes(
            .subfunction(Subfunction(name: "plus", patterns: [.variable("a"), .variable("b")], when: .bool(true), body: .call("+", [.variable("a"), .variable("b")])))
        )
        "[x|xs].map(f) = [f(x)|xs.map(f)]".makes(
            .subfunction(Subfunction(name: "map",
                                     patterns: [.listCons([.variable("x")], .variable("xs")), .variable("f")],
                                     when: .bool(true),
                                     body: .listCons([.call("f", [.variable("x")])],
                                                            .call("map", [.variable("xs"), .variable("f")]))))
        )
"""
a.foo =
 5
""".makes(.subfunction(Subfunction(name: "foo", patterns: [.variable("a")], when: .bool(true), body: .int(5))))
"""
foo() =
5
""".makes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .int(5))))
("foo() =" + " " + "\n5").makes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .int(5))))
"""
foo() =
  5
""".makes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .int(5))))
"""
foo() = Do
  5
End
""".makes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .scope([.int(5)]))))
"""
foo() =
Do
  5
End
""".makes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .scope([.int(5)]))))
"""
foo() = Do 5
End
""".makes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .scope([.int(5)]))))
"""
foo() = Do 5 End
""".makes(.subfunction(Subfunction(name: "foo", patterns: [], when: .bool(true), body: .scope([.int(5)]))))
    }

    func test_constants() {
        "x = 5".makes(.assign(variable: .variable("x"), value: .int(5)))
        "x=5".makes(.assign(variable: .variable("x"), value: .int(5)))
        "_ = 5".makes(.assign(variable: .ignore, value: .int(5)))
        "double = |x| x * 2".makes(.assign(variable: .variable("double"), value:
            .subfunction(Subfunction(name: nil,
                                     patterns: [.variable("x")],
                                     when: .bool(true),
                                     body: .call("*", [.variable("x"), .int(2)])))))

        "2 = 5".fails()
    }

    func test_lambdas() {
        "|x| x".makes(.subfunction(Subfunction(name: nil, patterns: [.variable("x")], when: .bool(true), body: .variable("x"))))
        "| x , y | x".makes(.subfunction(Subfunction(name: nil, patterns: [.variable("x"), .variable("y")], when: .bool(true), body: .variable("x"))))
"""
 |
 x
 ,
 y
 |
 x
""".makes(.subfunction(Subfunction(name: nil, patterns: [.variable("x"), .variable("y")], when: .bool(true), body: .variable("x"))))
        "|[x|xs], y| x".makes(.subfunction(Subfunction(name: nil, patterns: [.listCons([.variable("x")], .variable("xs")), .variable("y")], when: .bool(true), body: .variable("x"))))
        "|_| 5".makes(.subfunction(Subfunction(name: nil, patterns: [.ignore], when: .bool(true), body: .int(5))))
        "|| 5".makes(.subfunction(Subfunction(name: nil, patterns: [], when: .bool(true), body: .int(5))))
    }

    func test_negations() {
        "+5".makes(.int(5))
        "-5".makes(.call("-", [.int(5)]))
        "-x".makes(.call("-", [.variable("x")]))
        "-foo(1)".makes(.call("-", [.call("foo", [.int(1)])]))
        "--x".makes(.call("-", [.call("-", [.variable("x")])]))
        "Not x".makes(.call("Not", [.variable("x")]))
        "Not Not x".makes(.call("Not", [.call("Not", [.variable("x")])]))
        "9--5".makes(.call("-", [.int(9), .call("-", [.int(5)])]))
    }

    func test_calls() {
        "foo()".makes(.call("foo", []))
        "foo(a)".makes(.call("foo", [.variable("a")]))
        "foo(4)".makes(.call("foo", [.int(4)]))
        "4.foo".makes(.call("foo", [.int(4)]))
        "4.foo()".makes(.call("foo", [.int(4)]))
        "foo(x, y)".makes(.call("foo", [.variable("x"), .variable("y")]))
        "foo(x,y)".makes(.call("foo", [.variable("x"), .variable("y")]))
        "foo( x , y )".makes(.call("foo", [.variable("x"), .variable("y")]))
"""
foo(
  x
 ,
  y
 )
""".makes(.call("foo", [.variable("x"), .variable("y")]))
    }

    func test_callChains() {
        "3.foo.bar".makes(.call("bar", [.call("foo", [.int(3)])]))
        "3.foo().bar".makes(.call("bar", [.call("foo", [.int(3)])]))
        "3.foo.bar()".makes(.call("bar", [.call("foo", [.int(3)])]))
        "3.foo().bar()".makes(.call("bar", [.call("foo", [.int(3)])]))
        "3.foo(5).bar()".makes(.call("bar", [.call("foo", [.int(3), .int(5)])]))
        "3.foo(5).bar".makes(.call("bar", [.call("foo", [.int(3), .int(5)])]))
        "3.foo().bar(5)".makes(.call("bar", [.call("foo", [.int(3)]), .int(5)]))
        "3.foo.bar(5)".makes(.call("bar", [.call("foo", [.int(3)]), .int(5)]))
        "3.foo(9).bar(5)".makes(.call("bar", [.call("foo", [.int(3), .int(9)]), .int(5)]))
        "foo().bar".makes(.call("bar", [.call("foo", [])]))
        "foo().bar()".makes(.call("bar", [.call("foo", [])]))
        "foo(3).bar()".makes(.call("bar", [.call("foo", [.int(3)])]))
    }

    func test_nestedCalls() {

        "foo(bar())".makes(.call("foo", [.call("bar", [])]))
        "foo(bar(4))".makes(.call("foo", [.call("bar", [.int(4)])]))
        "foo(1, bar(4))".makes(.call("foo", [
            .int(1),
            .call("bar", [.int(4)])]))
        "1.foo(bar(4))".makes(.call("foo", [
            .int(1),
            .call("bar", [.int(4)])]))

        "foo( x( a , b ) , y( c , d) )".makes(
            .call("foo", [
                .call("x", [.variable("a"), .variable("b")]),
                .call("y", [.variable("c"), .variable("d")])
                ]))

        "3.foo(5.bar(6.foo(9)).foo()).bar(foo(3).bar)".makes(
            .call("bar", [
                .call("foo", [
                    .int(3),
                    .call("foo", [
                        .call("bar", [
                            .int(5),
                            .call("foo", [
                                .int(6),
                                .int(9)
                                ])
                            ])
                        ])
                    ]),
                .call("bar", [
                    .call("foo", [.int(3)])
                    ])
                ]))
    }

    func test_scopes() {
        "Do _ End".makes(.scope([.ignore]))
        "Do 1 End".makes(.scope([.int(1)]))
        "Do 1, End".makes(.scope([.int(1)]))
        "Do 1, x End".makes(.scope([.int(1), .variable("x")]))
        "Do 1 , x End".makes(.scope([.int(1), .variable("x")]))
        "Do 1, x, End".makes(.scope([.int(1), .variable("x")]))
        "Do x = 5, x End".makes(.scope([.assign(variable: .variable("x"), value: .int(5)), .variable("x")]))
        "Do |x| x End".makes(.scope([.subfunction(Subfunction(name: nil, patterns: [.variable("x")], when: .bool(true), body: .variable("x")))]))
        "Do x.inc = x+1, 7.inc End".makes(.scope([
            .subfunction(Subfunction(name: "inc", patterns: [.variable("x")], when: .bool(true), body: .call("+", [.variable("x"), .int(1)]))),
            .call("inc", [.int(7)])]))
        "Do 1, Do Do 2, 3 End, 4, End, End".makes(.scope([.int(1), .scope([.scope([.int(2), .int(3)]), .int(4)])]))

"""
Do 1
2
3 End
""".makes(.scope([.int(1), .int(2), .int(3)]))
"""
Do
  1
  2
  3
End
""".makes(.scope([.int(1), .int(2), .int(3)]))
"""
Do 1
2,3 End
""".makes(.scope([.int(1), .int(2), .int(3)]))
"""
Do
  1
  2
  3
End
""".makes(.scope([.int(1), .int(2), .int(3)]))
"""
Do
  1 , 2
  3
End
""".makes(.scope([.int(1), .int(2), .int(3)]))
"""
Do
  1,
  2,
  3
End
""".makes(.scope([.int(1), .int(2), .int(3)]))
"""
Do
  1,
  2,
  3,
End
""".makes(.scope([.int(1), .int(2), .int(3)]))

        "DoEnd".fails()
        "Do End".fails()
        "Do , End".fails()
        "Do,End".fails()
        "Do1End".fails()
    }

    func test_unusualFunctionCalls() {
        "(1 < 10).negate".makes(.call("negate", [.call("<", [.int(1), .int(10)])]))
        "(Do 5, 8 End).inc".makes(.call("inc", [.scope([.int(5), .int(8)])]))
        "(Do |x| x+1 End)(5)".makes(.callAnon(.scope([.subfunction(Subfunction(name: nil, patterns: [.variable("x")], when: .bool(true), body: .call("+", [.variable("x"), .int(1)])))]), [.int(5)]))
        "(inc(1)).inc".makes(.call("inc", [.call("inc", [.int(1)])]))
        "(x)()".makes(.callAnon(.variable("x"), []))
        "5.lessThan()(4)".makes(.callAnon(.call("lessThan", [.int(5)]), [.int(4)]))
        "(5.lessThan())(4)".makes(.callAnon(.call("lessThan", [.int(5)]), [.int(4)]))
        "(5.lessThan)(4)".makes(.callAnon(.call("lessThan", [.int(5)]), [.int(4)]))
        "lessThan(5)(4)".makes(.callAnon(.call("lessThan", [.int(5)]), [.int(4)]))
        "(|x| x+1)(4)".makes(
            .callAnon(
                .subfunction(Subfunction(name: nil,
                                                  patterns: [.variable("x")],
                                                  when: .bool(true),
                                                  body: .call("+", [.variable("x"), .int(1)])
                )),
                [.int(4)]))
        "4.(|x| x+1)".makes(
            .callAnon(
                .subfunction(Subfunction(name: nil,
                                                  patterns: [.variable("x")],
                                                  when: .bool(true),
                                                  body: .call("+", [.variable("x"), .int(1)])
                )),
                [.int(4)]))
        "4.(|x| x+1)()".makes(
            .callAnon(
                .callAnon(
                    .subfunction(Subfunction(name: nil,
                                                      patterns: [.variable("x")],
                                                      when: .bool(true),
                                                      body: .call("+", [.variable("x"), .int(1)])
                    )),
                    [.int(4)]
                ), []))
    }
}
