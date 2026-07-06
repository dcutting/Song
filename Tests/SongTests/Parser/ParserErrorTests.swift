import XCTest
@testable import SongLang

class ParserErrorTests: XCTestCase {
    func test_parse_givenIncompleteExpression_returnsIncomplete() {
        let result = SongParser().parseResult("foo(1")

        guard case .incomplete = result else {
            XCTFail("Expected incomplete parse, got \(result)")
            return
        }
    }

    func test_parse_givenInvalidExpression_returnsFailure() {
        let result = SongParser().parseResult("4()")

        guard case .failure = result else {
            XCTFail("Expected parse failure, got \(result)")
            return
        }
    }

    func test_parse_givenInvalidInteger_throws() {
        String(repeating: "9", count: 100).fails()
    }

    func test_parse_givenUnterminatedString_returnsIncomplete() {
        let result = SongParser().parseResult(#""hello"#)

        guard case .incomplete = result else {
            XCTFail("Expected incomplete parse, got \(result)")
            return
        }
    }

    func test_parse_givenIncompleteSubjectFunctionScope_returnsIncomplete() {
        let result = SongParser().parseResult("[[xm, x]|xs].sortMapped = Do")

        guard case .incomplete = result else {
            XCTFail("Expected incomplete parse, got \(result)")
            return
        }
    }
}
