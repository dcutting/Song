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

    func test_expressions_firstOpIsNotAFunctionCall_throws() {
        let transformer = makeTransformer()
        let result = Result.tagged(["left": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "ops": .series([
                                        .tagged(["integer": .match(match: "5", index: 0)])
                                        ])
            ])
        let remainder = Remainder(text: "", index: 0)
        XCTAssertThrowsError(try transformer.transform((result, remainder)))
    }

    func test_expressions_secondOpIsNotAFunctionCall_throws() {
        let transformer = makeTransformer()
        let result = Result.tagged(["left": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "ops": .series([
                                        .tagged(["right": .tagged(["integer": .match(match: "3", index: 0)]),
                                                 "op": .match(match: "+", index: 0)]),
                                        .tagged(["integer": .match(match: "5", index: 0)])
                                        ])
            ])
        let remainder = Remainder(text: "", index: 0)
        XCTAssertThrowsError(try transformer.transform((result, remainder)))
    }

    func test_functionCalls_noCallsPresent_throws() {
        let transformer = makeTransformer()
        let result = Result.tagged(["subject": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "calls": .series([])
            ])
        let remainder = Remainder(text: "", index: 0)
        XCTAssertThrowsError(try transformer.transform((result, remainder)))
    }

    func test_functionCalls_firstCallIsNotAFunctionCall_throws() {
        let transformer = makeTransformer()
        let result = Result.tagged(["subject": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "calls": .series([
                                        .tagged(["integer": .match(match: "5", index: 0)])
                                        ])
            ])
        let remainder = Remainder(text: "", index: 0)
        XCTAssertThrowsError(try transformer.transform((result, remainder)))
    }

    func test_functionCalls_secondCallIsNotAFunctionCall_throws() {
        let transformer = makeTransformer()
        let result = Result.tagged(["subject": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "calls": .series([
                                        .tagged([
                                            "functionName": .match(match: "foo", index: 0),
                                            "args": .series([])]),
                                        .tagged(["integer": .match(match: "5", index: 0)])
                                        ])
            ])
        let remainder = Remainder(text: "", index: 0)
        XCTAssertThrowsError(try transformer.transform((result, remainder)))
    }
}
