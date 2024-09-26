import XCTest
@testable import SongLang

class AssignParserTests: XCTestCase {
    func test_shouldParse() {
        "x = 5".makes(.assign(variable: .name("x"), value: .int(5)))
        "x= 5".makes(.assign(variable: .name("x"), value: .int(5)))
        "x =5".makes(.assign(variable: .name("x"), value: .int(5)))
        " x = 5 ".makes(.assign(variable: .name("x"), value: .int(5)))
        "x=5".makes(.assign(variable: .name("x"), value: .int(5)))
        "_ = 5".makes(.assign(variable: .unnamed, value: .int(5)))
        "x = y".makes(.assign(variable: .name("x"), value: .name("y")))
        "x = 'Z'".makes(.assign(variable: .name("x"), value: .char("Z")))
        "abc = Yes".makes(.assign(variable: .name("abc"), value: .bool(true)))
        #"abc = "hello""#.makes(.assign(variable: .name("abc"), value: .string("hello")))
        "double = |x| x * 2".makes(.assign(variable: .name("double"), value:
            .function(Function(name: nil,
                               patterns: [.name("x")],
                               when: .yes,
                               body: .call("*", [.name("x"), .int(2)])))))
    }

    func test_shouldNotParse() {
        "2 = 5".fails()
        "(x) = 5".fails()
    }
}
