//import XCTest
//@testable import SongLang
//
//class InOutTests: XCTestCase {
//
//    func test_out_characterValue_doesNotIncludeQuotes() {
//        let char = Expression.char("A")
//        let actual = char.out()
//        XCTAssertEqual("A", actual)
//    }
//
//    func test_out_stringValue_doesNotIncludeQuotes() {
//        let string = Expression.string("foo")
//        let actual = string.out()
//        XCTAssertEqual("foo", actual)
//    }
//
//    func test_out_closureValue_doesNotIncludeContext() {
//        let function = Expression.function(Function(name: "foo", patterns: [], when: .yes, body: .int(99)))
//        let context: Context = ["a": .int(5)]
//        let string = Expression.closure("foo", [function], context)
//        let actual = string.out()
//        XCTAssertEqual("[foo() = 99]", actual)
//    }
//
//    func test_out_integerValue() {
//        let string = Expression.int(5)
//        let actual = string.out()
//        XCTAssertEqual("5", actual)
//    }
//
//    func test_evaluate_noArguments_emptyString() {
//        assertNoThrow {
//            let call = Expression.call("out", [])
//            XCTAssertEqual(Expression.string(""), try call.evaluate())
//        }
//    }
//
//    func test_evaluate_oneArgument_descriptionOfArgument() {
//        assertNoThrow {
//            let call = Expression.call("out", [.int(99)])
//            XCTAssertEqual(Expression.string("99"), try call.evaluate())
//        }
//    }
//
//    func test_evaluate_multipleArguments_joinsWithSpace() {
//        assertNoThrow {
//            let stdOut = SpyStdOut()
//            _stdOut = stdOut
//            let call = Expression.call("out", [.int(99), .string("is in"), .list([.yes, .int(99)])])
//            XCTAssertEqual(Expression.string("99 is in [Yes, 99]"), try call.evaluate())
//            XCTAssertEqual("99 is in [Yes, 99]\n", stdOut.actual)
//        }
//    }
//
//    func test_evaluate_err() {
//        assertNoThrow {
//            let stdErr = SpyStdOut()
//            _stdErr = stdErr
//            let call = Expression.call("err", [.int(99), .string("is in"), .list([.yes, .int(99)])])
//            XCTAssertEqual(Expression.string("99 is in [Yes, 99]"), try call.evaluate())
//            XCTAssertEqual("99 is in [Yes, 99]\n", stdErr.actual)
//        }
//    }
//
//    func test_evaluate_in() {
//        assertNoThrow {
//            let stdIn = StubStdIn("Dan")
//            let stdOut = SpyStdOut()
//            _stdIn = stdIn
//            _stdOut = stdOut
//            let call = Expression.call("in", [.string("Your name? ")])
//            XCTAssertEqual(Expression.string("Dan"), try call.evaluate())
//            XCTAssertEqual("Your name? ", stdOut.actual)
//        }
//    }
//
//    func test_evaluate_in_nilInput_returnsEmptyString() {
//        assertNoThrow {
//            let stdIn = StubStdIn(nil)
//            _stdIn = stdIn
//            let call = Expression.call("in", [.string("Your name? ")])
//            XCTAssertEqual(Expression.string(""), try call.evaluate())
//        }
//    }
//}
//
//class StubStdIn: StdIn {
//
//    private var stubbed: String?
//
//    init(_ stubbed: String?) {
//        self.stubbed = stubbed
//    }
//
//    func get() -> String? {
//        return stubbed
//    }
//}
//
//class SpyStdOut: StdOut {
//
//    var actual: String?
//
//    func put(_ output: String) {
//        actual = output
//    }
//}
