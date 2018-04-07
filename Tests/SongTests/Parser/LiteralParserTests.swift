import XCTest
import Song

class LiteralParserTests: XCTestCase {

    func test_bools() {
        "Yes".makes(.yes)
        "No".makes(.no)
        " Yes ".makes(.yes)
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
        "'é'".makes(.char("é"))
        "'😀'".makes(.char("😀"))
        "' '".makes(.char(" "))
        "'\\''".makes(.char("'"))
        "'\"'".makes(.char("\""))
        "'\\\\'".makes(.char("\\"))
        "'\n'".makes(.char("\n"))
        "'AB'".fails()
        "'''".fails()
    }

    func test_strings() {
        "\"\"".makes(.string(""))
        "\"'\"".makes(.string("'"))
        "\"hello world\"".makes(.string("hello world"))
"""
\"hello
world\"
""".makes(.string("hello\nworld"))
        "\"café\"".makes(.string("café"))
        "\"😀\"".makes(.string("😀"))
        "\"Hi, I said\"".makes(.string("Hi, I said"))
        "\"\\\"Hi,\\\" I said\"".makes(.string("\"Hi,\" I said"))
        "\"\n\"".makes(.string("\n"))
        "\"a\\\\backslash\"".makes(.string("a\\backslash"))
        " \"hello world\" ".makes(.string("hello world"))
    }

    func test_lists() {
        "[]".makes(.list([]))
        " [] ".makes(.list([]))
        "[1,No]".makes(.list([.int(1), .no]))
        "[ 1 , Yes , \"hi\" ]".makes(.list([.int(1), .yes, .string("hi")]))
        "[[1,2],[No,4], [], \"hi\"]".makes(.list([
            .list([.int(1), .int(2)]),
            .list([.no, .int(4)]),
            .list([]),
            .string("hi")
            ]))
        """
[
  1 ,

  No
]
""".makes(.list([.int(1), .no]))
    }

    func test_cons() {
        "[x|xs]".makes(.cons([.name("x")], .name("xs")))
        "[x,y|xs]".makes(.cons([.name("x"), .name("y")], .name("xs")))
        "[ 1 , x | xs ]".makes(.cons([.int(1), .name("x")], .name("xs")))
        "[Yes|2]".makes(.cons([.yes], .int(2)))
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
}
