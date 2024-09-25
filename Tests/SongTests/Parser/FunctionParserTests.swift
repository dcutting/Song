import XCTest
@testable import SongLang

class FunctionParserTests: XCTestCase {

    func test_shouldParse() {
        "foo() = 5".makes(
            .function(Function(name: "foo", patterns: [], when: .yes, body: .int(5)))
        )
        "foo(a) = a".makes(
            .function(Function(name: "foo", patterns: [.name("a")], when: .yes, body: .name("a")))
        )
        """
foo(a,
    b) = a
""".makes(.function(Function(name: "foo", patterns: [.name("a"), .name("b")], when: .yes, body: .name("a"))))
        """
foo(
  a,
  b
) = a
""".makes(.function(Function(name: "foo", patterns: [.name("a"), .name("b")], when: .yes, body: .name("a"))))
        "a.foo = a".makes(
            .function(Function(name: "foo", patterns: [.name("a")], when: .yes, body: .name("a")))
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
            .function(Function(name: "plus", patterns: [.name("a"), .name("b")], when: .yes, body: .call("+", [.name("a"), .name("b")])))
        )
        "[x|xs].map(f) = [f(x)|xs.map(f)]".makes(
            .function(Function(name: "map",
                               patterns: [.cons([.name("x")], .name("xs")), .name("f")],
                               when: .yes,
                               body: .cons([.call("f", [.name("x")])],
                                           .call("map", [.name("xs"), .name("f")]))))
        )
        """
a.foo =
 5
""".makes(.function(Function(name: "foo", patterns: [.name("a")], when: .yes, body: .int(5))))
        """
foo() =
5
""".makes(.function(Function(name: "foo", patterns: [], when: .yes, body: .int(5))))
        ("foo() =" + " " + "\n5").makes(.function(Function(name: "foo", patterns: [], when: .yes, body: .int(5))))
        """
foo() =
  5
""".makes(.function(Function(name: "foo", patterns: [], when: .yes, body: .int(5))))
        """
foo() = Do
  5
End
""".makes(.function(Function(name: "foo", patterns: [], when: .yes, body: .scope([.int(5)]))))
        """
foo() =
Do
  5
End
""".makes(.function(Function(name: "foo", patterns: [], when: .yes, body: .scope([.int(5)]))))
        """
foo() = Do 5
End
""".makes(.function(Function(name: "foo", patterns: [], when: .yes, body: .scope([.int(5)]))))
        """
foo() = Do 5 End
""".makes(.function(Function(name: "foo", patterns: [], when: .yes, body: .scope([.int(5)]))))
    }

    func test_shouldNotParse() {
        "foo((x)) = x".fails()
        "(x).foo = x".fails()
    }
}
