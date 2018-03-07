import XCTest
import Song

class EvaluationErrorTests: XCTestCase {

    func test_stackTrace() {
        let error = EvaluationError.cannotEvaluate(.variable("foo"), .cannotEvaluate(.variable("bar"), .symbolNotFound("baz")))
        let expected = """
Evaluation error
 ↳ foo
  ↳ bar
   💥  unknown symbol: baz
"""
        XCTAssertEqual(expected, format(error: error))
    }

    func test_symbolNotFound() {
        let error = EvaluationError.symbolNotFound("foo")
        XCTAssertEqual("Evaluation error\n 💥  unknown symbol: foo", format(error: error))
    }

    func test_signatureMismatch() {
        let error = EvaluationError.signatureMismatch([.integerValue(1)])
        XCTAssertEqual("Evaluation error\n 💥  no pattern matches arguments: [1]", format(error: error))
    }

    func test_notAClosure() {
        let error = EvaluationError.notAClosure(.integerValue(1))
        XCTAssertEqual("Evaluation error\n 💥  need a closure, not 1", format(error: error))
    }

    func test_notABoolean() {
        let error = EvaluationError.notABoolean(.integerValue(1))
        XCTAssertEqual("Evaluation error\n 💥  need a boolean, not 1", format(error: error))
    }

    func test_notANumber() {
        let error = EvaluationError.notANumber(.bool(true))
        XCTAssertEqual("Evaluation error\n 💥  need a number, not Yes", format(error: error))
    }

    func test_notAList() {
        let error = EvaluationError.notAList(.bool(true))
        XCTAssertEqual("Evaluation error\n 💥  need a list, not Yes", format(error: error))
    }

    func test_notAFunction() {
        let error = EvaluationError.notAFunction(.bool(true))
        XCTAssertEqual("Evaluation error\n 💥  need a function, not Yes", format(error: error))
    }

    func test_patternsCannotBeFloats() {
        let error = EvaluationError.patternsCannotBeFloats(.floatValue(2.0))
        XCTAssertEqual("Evaluation error\n 💥  patterns cannot be floats: 2.0", format(error: error))
    }

    func test_numericMismatch() {
        let error = EvaluationError.numericMismatch
        XCTAssertEqual("Evaluation error\n 💥  can only use integers here", format(error: error))
    }

    func test_emptyScope() {
        let error = EvaluationError.emptyScope
        XCTAssertEqual("Evaluation error\n 💥  Do/End must contain at least one expression", format(error: error))
    }

    func test_notACharacter() {
        let error = EvaluationError.notACharacter
        XCTAssertEqual("Evaluation error\n 💥  need a character", format(error: error))
    }
}
