import XCTest
import Song

class ParserTests: XCTestCase {

    func test_bools() {
        "Yes".makes(.bool(true))
        "No".makes(.bool(false))
        " Yes ".makes(.bool(true))
    }

    func test_ints() {
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

    func test_chars() {
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

    func test_cons() {
        "[x|xs]".makes(.cons([.name("x")], .name("xs")))
        "[x,y|xs]".makes(.cons([.name("x"), .name("y")], .name("xs")))
        "[ 1 , x | xs ]".makes(.cons([.int(1), .name("x")], .name("xs")))
        "[Yes|2]".makes(.cons([.bool(true)], .int(2)))
        "[ f(x) | g(x) ]".makes(.cons([.call("f", [.name("x")])],
                                                   .call("g", [.name("x")])))
        "[1,2|[3,4|[5,6]]]".makes(.cons(
            [.int(1), .int(2)],
            .cons(
                [.int(3), .int(4)],
                .list([.int(5), .int(6)])
            )))
"""
[
 x, y
 |
 xs
]
""".makes(.cons([.name("x"), .name("y")], .name("xs")))

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
        "x Eq 5".makes(.call("Eq", [.name("x"), .int(5)]))
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

    func test_names() {
        "_".makes(.ignore)
        "x".makes(.name("x"))
        "_x".makes(.name("_x"))
        "_private".makes(.name("_private"))
        "goodName".makes(.name("goodName"))
        "good_name".makes(.name("good_name"))
        "goodName99".makes(.name("goodName99"))
        "good_".makes(.name("good_"))

        "GoodName".fails()
        "9bottles".fails()
    }

    func test_functions() {
        "foo() = 5".makes(
            .function(Function(name: "foo", patterns: [], when: .bool(true), body: .int(5)))
        )
        "foo(a) = a".makes(
            .function(Function(name: "foo", patterns: [.name("a")], when: .bool(true), body: .name("a")))
        )
"""
foo(a,
    b) = a
""".makes(.function(Function(name: "foo", patterns: [.name("a"), .name("b")], when: .bool(true), body: .name("a"))))
"""
foo(
  a,
  b
) = a
""".makes(.function(Function(name: "foo", patterns: [.name("a"), .name("b")], when: .bool(true), body: .name("a"))))
        "a.foo = a".makes(
            .function(Function(name: "foo", patterns: [.name("a")], when: .bool(true), body: .name("a")))
        )
        "a.foo When a < 50 = a".makes(
            .function(Function(name: "foo",
                                     patterns: [.name("a")],
                                     when: .call("<", [.name("a"), .int(50)]),
                                     body: .name("a")))
        )
        "a.foo() When a < 50 = a".makes(
            .function(Function(name: "foo",
                                     patterns: [.name("a")],
                                     when: .call("<", [.name("a"), .int(50)]),
                                     body: .name("a")))
        )
        "a.plus(b) = a + b".makes(
            .function(Function(name: "plus", patterns: [.name("a"), .name("b")], when: .bool(true), body: .call("+", [.name("a"), .name("b")])))
        )
        "[x|xs].map(f) = [f(x)|xs.map(f)]".makes(
            .function(Function(name: "map",
                                     patterns: [.cons([.name("x")], .name("xs")), .name("f")],
                                     when: .bool(true),
                                     body: .cons([.call("f", [.name("x")])],
                                                            .call("map", [.name("xs"), .name("f")]))))
        )
"""
a.foo =
 5
""".makes(.function(Function(name: "foo", patterns: [.name("a")], when: .bool(true), body: .int(5))))
"""
foo() =
5
""".makes(.function(Function(name: "foo", patterns: [], when: .bool(true), body: .int(5))))
("foo() =" + " " + "\n5").makes(.function(Function(name: "foo", patterns: [], when: .bool(true), body: .int(5))))
"""
foo() =
  5
""".makes(.function(Function(name: "foo", patterns: [], when: .bool(true), body: .int(5))))
"""
foo() = Do
  5
End
""".makes(.function(Function(name: "foo", patterns: [], when: .bool(true), body: .scope([.int(5)]))))
"""
foo() =
Do
  5
End
""".makes(.function(Function(name: "foo", patterns: [], when: .bool(true), body: .scope([.int(5)]))))
"""
foo() = Do 5
End
""".makes(.function(Function(name: "foo", patterns: [], when: .bool(true), body: .scope([.int(5)]))))
"""
foo() = Do 5 End
""".makes(.function(Function(name: "foo", patterns: [], when: .bool(true), body: .scope([.int(5)]))))
    }

    func test_assigns() {
        "x = 5".makes(.assign(variable: .name("x"), value: .int(5)))
        "x=5".makes(.assign(variable: .name("x"), value: .int(5)))
        "_ = 5".makes(.assign(variable: .ignore, value: .int(5)))
        "double = |x| x * 2".makes(.assign(variable: .name("double"), value:
            .function(Function(name: nil,
                                     patterns: [.name("x")],
                                     when: .bool(true),
                                     body: .call("*", [.name("x"), .int(2)])))))

        "2 = 5".fails()
    }

    func test_lambdas() {
        "|x| x".makes(.function(Function(name: nil, patterns: [.name("x")], when: .bool(true), body: .name("x"))))
        "| x , y | x".makes(.function(Function(name: nil, patterns: [.name("x"), .name("y")], when: .bool(true), body: .name("x"))))
"""
 |
 x
 ,
 y
 |
 x
""".makes(.function(Function(name: nil, patterns: [.name("x"), .name("y")], when: .bool(true), body: .name("x"))))
        "|[x|xs], y| x".makes(.function(Function(name: nil, patterns: [.cons([.name("x")], .name("xs")), .name("y")], when: .bool(true), body: .name("x"))))
        "|_| 5".makes(.function(Function(name: nil, patterns: [.ignore], when: .bool(true), body: .int(5))))
        "|| 5".makes(.function(Function(name: nil, patterns: [], when: .bool(true), body: .int(5))))
    }

    func test_negations() {
        "+5".makes(.int(5))
        "-5".makes(.call("-", [.int(5)]))
        "-x".makes(.call("-", [.name("x")]))
        "-foo(1)".makes(.call("-", [.call("foo", [.int(1)])]))
        "--x".makes(.call("-", [.call("-", [.name("x")])]))
        "Not x".makes(.call("Not", [.name("x")]))
        "Not Not x".makes(.call("Not", [.call("Not", [.name("x")])]))
        "9--5".makes(.call("-", [.int(9), .call("-", [.int(5)])]))
    }

    func test_scopes() {
        "Do _ End".makes(.scope([.ignore]))
        "Do 1 End".makes(.scope([.int(1)]))
        "Do 1, End".makes(.scope([.int(1)]))
        "Do 1, x End".makes(.scope([.int(1), .name("x")]))
        "Do 1 , x End".makes(.scope([.int(1), .name("x")]))
        "Do 1, x, End".makes(.scope([.int(1), .name("x")]))
        "Do x = 5, x End".makes(.scope([.assign(variable: .name("x"), value: .int(5)), .name("x")]))
        "Do |x| x End".makes(.scope([.function(Function(name: nil, patterns: [.name("x")], when: .bool(true), body: .name("x")))]))
        "Do x.inc = x+1, 7.inc End".makes(.scope([
            .function(Function(name: "inc", patterns: [.name("x")], when: .bool(true), body: .call("+", [.name("x"), .int(1)]))),
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
}
