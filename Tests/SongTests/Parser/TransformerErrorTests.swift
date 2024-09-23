import XCTest
import SongLang
@testable import Syft

class TransformerErrorTests: XCTestCase {

    let transformer = makeTransformer()
    let dummyRemainder = Remainder(text: "", index: 0)

    func test_integerValue_givenString_throws() {
        let result = Result.tagged(["integer": .match(match: "invalid_integer", index: 0)])
        XCTAssertThrowsError(try transformer.transform((result, dummyRemainder)))
    }

    func test_floatValue_givenString_throws() {
        let result = Result.tagged(["float": .match(match: "invalid_float", index: 0)])
        XCTAssertThrowsError(try transformer.transform((result, dummyRemainder)))
    }

    func test_expressions_firstOpIsNotAFunctionCall_throws() {
        let result = Result.tagged(["left": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "ops": .series([
                                        .tagged(["integer": .match(match: "5", index: 0)])
                                        ])
            ])
        XCTAssertThrowsError(try transformer.transform((result, dummyRemainder)))
    }

    func test_expressions_secondOpIsNotAFunctionCall_throws() {
        let result = Result.tagged(["left": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "ops": .series([
                                        .tagged(["right": .tagged(["integer": .match(match: "3", index: 0)]),
                                                 "op": .match(match: "+", index: 0)]),
                                        .tagged(["integer": .match(match: "5", index: 0)])
                                        ])
            ])
        XCTAssertThrowsError(try transformer.transform((result, dummyRemainder)))
    }

    func test_functionCalls_noCallsPresent_throws() {
        let result = Result.tagged(["subject": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "calls": .series([])
            ])
        XCTAssertThrowsError(try transformer.transform((result, dummyRemainder)))
    }

    func test_functionCalls_firstCallIsNotAFunctionCall_throws() {
        let result = Result.tagged(["subject": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "calls": .series([
                                        .tagged(["integer": .match(match: "5", index: 0)])
                                        ])
            ])
        XCTAssertThrowsError(try transformer.transform((result, dummyRemainder)))
    }

    func test_functionCalls_secondCallIsNotAFunctionCall_throws() {
        let result = Result.tagged(["subject": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "calls": .series([
                                        .tagged([
                                            "functionName": .match(match: "foo", index: 0),
                                            "args": .series([])]),
                                        .tagged(["integer": .match(match: "5", index: 0)])
                                        ])
            ])
        XCTAssertThrowsError(try transformer.transform((result, dummyRemainder)))
    }

    func test_functionCalls_nameCallIsNotAFunctionCall_throws() {
        let result = Result.tagged(["head": .tagged(["integer": .match(match: "9", index: 0)]),
                                    "nameCall": .tagged(["integer": .match(match: "9", index: 0)])])
        XCTAssertThrowsError(try transformer.transform((result, dummyRemainder)))
    }

    func test_functionCalls_anonCallIsNotListOfArgs_throws() {
        let result = Result.tagged(["anonCall": .tagged(["integer": .match(match: "9", index: 0)])])
        XCTAssertThrowsError(try transformer.transform((result, dummyRemainder)))
    }

    func test_reduceCalls_noneSupplied_throws() {
        let result = Result.tagged(["dotCall": .series([])])
        XCTAssertThrowsError(try transformer.transform((result, dummyRemainder)))
    }

    func test_reduceCalls_secondCallIsNotACall_throws() {
        let result = Result.tagged(["dotCall": .series([
            .tagged([
                "functionName": .match(match: "foo", index: 0),
                "args": .series([])]),
            .tagged(["integer": .match(match: "1", index: 0)])
            ])])
        XCTAssertThrowsError(try transformer.transform((result, dummyRemainder)))
    }
}
