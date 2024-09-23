import XCTest
import SongLang

class ExpressionParserTests: XCTestCase {

    func test_shouldParse() {
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
        "Do 2, 5 < 7 End And Do Yes End".makes(.call("And", [.scope([.int(2), .call("<", [.int(5), .int(7)])]), .scope([.yes])]))

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

    func test_shouldNotParse() {
        "12 Div5".fails()
        "12 Mod5".fails()
        "12Div 5".fails()
        "12Mod 5".fails()
    }

    func test_wrapped() {
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

    func test_negated() {
        "+5".makes(.int(5))
        "-5".makes(.call("-", [.int(5)]))
        "-x".makes(.call("-", [.name("x")]))
        "-foo(1)".makes(.call("-", [.call("foo", [.int(1)])]))
        "--x".makes(.call("-", [.call("-", [.name("x")])]))
        "Not x".makes(.call("Not", [.name("x")]))
        "Not Not x".makes(.call("Not", [.call("Not", [.name("x")])]))
        "9--5".makes(.call("-", [.int(9), .call("-", [.int(5)])]))
    }
}
