import XCTest
import Song

class ClosureTests: XCTestCase {

    lazy var function = makeNamedFunction()

    let context: Context = ["x": .integerValue(5), "y": .stringValue("hi")]
    
    func testDescription() {
        assertNoThrow {
            let closure = try function.evaluate(context: context)
            let result = "\(closure)"
            XCTAssertEqual("[(x: 5, y: \"hi\") [foo(a, b) When Yes = x]]", result)
        }
    }
    
    func testEvaluate() {
        assertNoThrow {
            let closure = try function.evaluate(context: context)
            let result = try closure.evaluate()
            XCTAssertEqual(closure, result)
        }
    }

    private func makeNamedFunction() -> Expression {
        let subfunction = Subfunction(name: "foo",
                                      patterns: [ Expression.variable("a"), Expression.variable("b") ],
                                      when: Expression.bool(true),
                                      body: Expression.variable("x"))
        return .subfunction(subfunction)
    }
}
