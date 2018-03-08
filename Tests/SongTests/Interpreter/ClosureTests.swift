import XCTest
import Song

class ClosureTests: XCTestCase {

    lazy var function = makeNamedFunction()

    let context: Context = ["x": .int(5), "y": .string("hi")]
    
    func testDescription() {
        assertNoThrow {
            let closure = try function.evaluate(context: context)
            let result = "\(closure)"
            XCTAssertEqual("[(x: 5, y: \"hi\") [foo(a, b) = x]]", result)
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
        let subfunction = Function(name: "foo",
                                      patterns: [ Expression.name("a"), Expression.name("b") ],
                                      when: Expression.bool(true),
                                      body: Expression.name("x"))
        return .function(subfunction)
    }
}
