import XCTest
@testable import SongLang

class ScopeParserTests: XCTestCase {

    func test_shouldParse() {
        "Do _ End".makes(.scope([.unnamed]))
        "Do 1 End".makes(.scope([.int(1)]))
        "Do 1, x End".makes(.scope([.int(1), .name("x")]))
        "Do 1 , x End".makes(.scope([.int(1), .name("x")]))
        "Do x = 5, x End".makes(.scope([.assign(variable: .name("x"), value: .int(5)), .name("x")]))
        "Do |x| x End".makes(.scope([.function(Function(name: nil, patterns: [.name("x")], when: .yes, body: .name("x")))]))
        "Do x.inc = x+1, 7.inc End".makes(.scope([
            .function(Function(name: "inc", patterns: [.name("x")], when: .yes, body: .call("+", [.name("x"), .int(1)]))),
            .call("inc", [.int(7)])]))
        "Do 1, Do Do 2, 3 End, 4 End End".makes(.scope([.int(1), .scope([.scope([.int(2), .int(3)]), .int(4)])]))

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
    }

    func test_shouldNotParse() {
        "DoEnd".fails()
        "Do End".fails()
        "Do , End".fails()
        "Do,End".fails()
        "Do1End".fails()
        "Do 1, End".fails()
        "Do 1, x, End".fails()
        """
Do
  1,
  2,
  3,
End
""".fails()
    }
}
