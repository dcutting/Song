import XCTest
import Song

class TailCallTests: XCTestCase {

    func test_description_tailCall() {
        let tailCall = Expression.tailEval(.int(1), [.int(0)])
        let result = "\(tailCall)"
        XCTAssertEqual("1(0)", result)
    }

    func test_deepRecursion_bodyIsTailCall() {
        assertNoThrow {
            let fb = Function(name: "times", patterns: [.name("n")], when: .call("Eq", [.name("n"), .int(0)]), body: .name("n"))
            let fr = Function(name: "times", patterns: [.name("n")], when: .yes, body: .call("times", [.call("-", [.name("n"), .int(1)])]))
            let context = try! declareSubfunctions([fb, fr])

            let e = Expression.call("times", [.int(5000)])

            let actual = try e.evaluate(context: context)
            let expected = Expression.int(0)
            XCTAssertEqual(expected, actual)
        }
    }

    func test_deepRecursion_bodyIsScopeWithTailCall() {
        assertNoThrow {
            let fb = Function(name: "times", patterns: [.name("n")], when: .call("Eq", [.name("n"), .int(0)]), body: .scope([.name("n")]))
            let fr = Function(name: "times", patterns: [.name("n")], when: .yes, body: .scope([.call("times", [.call("-", [.name("n"), .int(1)])])]))
            let context = try! declareSubfunctions([fb, fr])

            let e = Expression.call("times", [.int(5000)])

            let actual = try e.evaluate(context: context)
            let expected = Expression.int(0)
            XCTAssertEqual(expected, actual)
        }
    }

    func test_tailCallIsParameter() {
        assertNoThrow {
            let foo = Function(name: "foo", patterns: [.name("f")], when: .yes, body: .call("f", []))
            let context = try declareSubfunctions([foo])
            let call = Expression.call("foo", [.lambda([], .int(5))])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.int(5), actual)
        }
    }

    func test_tailCallIsBuiltIn() {
        assertNoThrow {
            let foo = Function(name: "foo", patterns: [], when: .yes, body: .call("+", [.int(1), .int(2)]))
            let context = try declareSubfunctions([foo])
            let call = Expression.call("foo", [])
            let actual = try call.evaluate(context: context)
            XCTAssertEqual(Expression.int(3), actual)
        }
    }
}
