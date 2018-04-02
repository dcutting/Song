import XCTest
import Song

class AssignParserTests: XCTestCase {

    func test_shouldParse() {
        "x = 5".makes(.assign(variable: .name("x"), value: .int(5)))
        "x=5".makes(.assign(variable: .name("x"), value: .int(5)))
        "_ = 5".makes(.assign(variable: .ignore, value: .int(5)))
        "double = |x| x * 2".makes(.assign(variable: .name("double"), value:
            .function(Function(name: nil,
                               patterns: [.name("x")],
                               when: .yes,
                               body: .call("*", [.name("x"), .int(2)])))))
    }

    func test_shouldNotParse() {
        "2 = 5".fails()
    }
}
