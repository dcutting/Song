import XCTest
@testable import SongLang

class ClosureTests: XCTestCase {

    lazy var function = makeNamedFunction()

    let context: Context = ["x": .int(5), "y": .string("hi")]
    
    func test_description() {
        assertNoThrow {
            let closure = try function.evaluate(context: context)
            let result = "\(closure)"
            XCTAssertEqual("[foo(a, b) = x]", result)
        }
    }
    
    func test_evaluate() {
        assertNoThrow {
            let closure = try function.evaluate(context: context)
            XCTAssertEqual(closure, try closure.evaluate())
        }
    }

    private func makeNamedFunction() -> SongLang.Expression {
        let function = Function(name: "foo",
                                patterns: [.name("a"), .name("b")],
                                when: .yes,
                                body: .name("x"))
        return .function(function)
    }
}
