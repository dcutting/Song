import XCTest
import Song

class TailCallTests: XCTestCase {

    func test_description_tailCall() {
        let context = extendContext(context: Context(), name: "x", value: .int(5))
        let tailCall = Expression.tailCall("recur", [.int(0)], context)
        let result = "\(tailCall)"
        XCTAssertEqual("[(x: 5) recur(0)]", result)
    }

    func test_deepRecursion_bodyIsTailCall() {
        assertNoThrow {
            let fb = Function(name: "times", patterns: [.name("n")], when: .call("Eq", [.name("n"), .int(0)]), body: .name("n"))
            let fr = Function(name: "times", patterns: [.name("n")], when: .bool(true), body: .call("times", [.call("-", [.name("n"), .int(1)])]))
            let context = try! declareSubfunctions([fb, fr])

            let e = Expression.call("times", [.int(50000)])

            let actual = try e.evaluate(context: context)
            let expected = Expression.int(0)
            XCTAssertEqual(expected, actual)
        }
    }

    func test_deepRecursion_bodyIsScopeWithTailCall() {
        assertNoThrow {
            let fb = Function(name: "times", patterns: [.name("n")], when: .call("Eq", [.name("n"), .int(0)]), body: .scope([.name("n")]))
            let fr = Function(name: "times", patterns: [.name("n")], when: .bool(true), body: .scope([.call("times", [.call("-", [.name("n"), .int(1)])])]))
            let context = try! declareSubfunctions([fb, fr])

            let e = Expression.call("times", [.int(50000)])

            let actual = try e.evaluate(context: context)
            let expected = Expression.int(0)
            XCTAssertEqual(expected, actual)
        }
    }
}
