import XCTest
import SongLang

class EvaluationErrorTests: XCTestCase {

    func test_stackTrace() {
        let error = EvaluationError.cannotEvaluate(.name("foo"), .cannotEvaluate(.name("bar"), .symbolNotFound("baz")))
        let expected = """
Evaluation error
 ↳ foo
  ↳ bar
   💥  unknown symbol: baz
"""
        XCTAssertEqual(expected, "\(error)")
    }

    func test_symbolNotFound() {
        let error = EvaluationError.symbolNotFound("foo")
        XCTAssertEqual("Evaluation error\n 💥  unknown symbol: foo", "\(error)")
    }

    func test_signatureMismatch() {
        let error = EvaluationError.signatureMismatch([.int(1)])
        XCTAssertEqual("Evaluation error\n 💥  no pattern matches arguments: [1]", "\(error)")
    }

    func test_notAClosure() {
        let error = EvaluationError.notAClosure(.int(1))
        XCTAssertEqual("Evaluation error\n 💥  need a closure, not 1", "\(error)")
    }

    func test_notABoolean() {
        let error = EvaluationError.notABoolean(.int(1))
        XCTAssertEqual("Evaluation error\n 💥  need a boolean, not 1", "\(error)")
    }

    func test_notANumber() {
        let error = EvaluationError.notANumber(.yes)
        XCTAssertEqual("Evaluation error\n 💥  need a number, not Yes", "\(error)")
    }

    func test_notAList() {
        let error = EvaluationError.notAList(.yes)
        XCTAssertEqual("Evaluation error\n 💥  need a list, not Yes", "\(error)")
    }

    func test_notAFunction() {
        let error = EvaluationError.notAFunction(.yes)
        XCTAssertEqual("Evaluation error\n 💥  need a function, not Yes", "\(error)")
    }

    func test_patternsCannotBeFloats() {
        let error = EvaluationError.patternsCannotBeFloats(.float(2.0))
        XCTAssertEqual("Evaluation error\n 💥  patterns cannot be floats: 2.0", "\(error)")
    }

    func test_numericMismatch() {
        let error = EvaluationError.numericMismatch
        XCTAssertEqual("Evaluation error\n 💥  can only use integers here", "\(error)")
    }

    func test_emptyScope() {
        let error = EvaluationError.emptyScope
        XCTAssertEqual("Evaluation error\n 💥  Do/End must contain at least one expression", "\(error)")
    }

    func test_notACharacter() {
        let error = EvaluationError.notACharacter
        XCTAssertEqual("Evaluation error\n 💥  need a character", "\(error)")
    }
}
