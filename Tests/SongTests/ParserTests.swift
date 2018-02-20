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

        "9d".fails()
    }

    func test_floats() {
        "0.1".becomes(.floatValue(0.1))
        "-9.1".becomes(.floatValue(-9.1))
        "0.001".becomes(.floatValue(0.001))

        ".1".fails()
    }

    func test_strings() {
        "\"hello world\"".becomes(.stringValue("hello world"))
        "\"\\\"Hi,\\\" I said\"".becomes(.stringValue("\\\"Hi,\\\" I said"))
    }

    func test_lists() {
        "[]".becomes(.list([]))
        "[1,no]".becomes(.list([.integerValue(1), .booleanValue(false)]))
        "[ 1 , yes , \"hi\" ]".becomes(.list([.integerValue(1), .booleanValue(true), .stringValue("hi")]))
    }

    func test_listConstructors() {
        "[x|xs]".becomes(.listConstructor([.variable("x")], .variable("xs")))
        "[x,y|xs]".becomes(.listConstructor([.variable("x"), .variable("y")], .variable("xs")))
        "[ 1 , x | xs ]".becomes(.listConstructor([.integerValue(1), .variable("x")], .variable("xs")))
        "[yes|2]".becomes(.listConstructor([.booleanValue(true)], .integerValue(2)))

        "[|xs]".fails()
        "[x|]".fails()
    }

    func test_variables() {
        "x".becomes(.variable("x"))
        "_x".becomes(.variable("_x"))
        "_private".becomes(.variable("_private"))
        "goodName".becomes(.variable("goodName"))
        "good_name".becomes(.variable("good_name"))
        "goodName99".becomes(.variable("goodName99"))
        "good_".becomes(.variable("good_"))

        "_".fails()
        "GoodName".fails()
        "9bottles".fails()
    }
}
