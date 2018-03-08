import XCTest
import Song

class FunctionParserTests: XCTestCase {

    func test_shouldParse() {
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
}
