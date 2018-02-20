import XCTest
import Song

class ParserTests: XCTestCase {

    func test_booleans() {
        "yes".becomes(.booleanValue(true))
        "no".becomes(.booleanValue(false))
    }

    func test_integers() {
        "99".becomes(.integerValue(99))
        "-21".becomes(.integerValue(-21))
        "0".becomes(.integerValue(0))
        "-0".becomes(.integerValue(0))
    }

    func test_floats() {
        "0.1".becomes(.floatValue(0.1))
        "-9.1".becomes(.floatValue(-9.1))
        "0.001".becomes(.floatValue(0.001))
    }

    func test_strings() {
        "\"hello world\"".becomes(.stringValue("hello world"))
        "\"\\\"Hi,\\\" I said\"".becomes(.stringValue("\\\"Hi,\\\" I said"))
    }

    func test_lists() {
        "[]".becomes(.list([]))
        "[1,2]".becomes(.list([.integerValue(1), .integerValue(2)]))
        "[ 1 , yes , \"hi\" ]".becomes(.list([.integerValue(1), .booleanValue(true), .stringValue("hi")]))
    }

    func test_listConstructor() {
        "[x|xs]".becomes(.listConstructor([.variable("x")], .variable("xs")))
        "[x,y|xs]".becomes(.listConstructor([.variable("x"), .variable("y")], .variable("xs")))
        "[ 1 , x | xs ]".becomes(.listConstructor([.integerValue(1), .variable("x")], .variable("xs")))
    }
}
