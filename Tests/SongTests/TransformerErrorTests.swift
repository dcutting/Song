import XCTest
import Song
@testable import Syft

class TransformerErrorTests: XCTestCase {

    func test_integerValue_givenString_throws() {
        let transformer = makeTransformer()
        let result = Result.tagged(["integer": .match(match: "invalid_integer", index: 0)])
        let remainder = Remainder(text: "", index: 0)
        XCTAssertThrowsError(try transformer.transform((result, remainder)))
    }

    func test_floatValue_givenString_throws() {
        let transformer = makeTransformer()
        let result = Result.tagged(["float": .match(match: "invalid_float", index: 0)])
        let remainder = Remainder(text: "", index: 0)
        XCTAssertThrowsError(try transformer.transform((result, remainder)))
    }

    func test_expressions_opIsNotAFunctionCall_throws() {
        let transformer = makeTransformer()
        let result = Result.tagged(["left": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "ops": .series([
                                        .tagged(["integer": .match(match: "5", index: 0)])
                                        ])
            ])
        let remainder = Remainder(text: "", index: 0)
        XCTAssertThrowsError(try transformer.transform((result, remainder)))
    }
}
