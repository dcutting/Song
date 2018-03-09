import XCTest
import Song

class FibonacciTests: XCTestCase {

    func test() {
        let code = """
n.fib = n.fib(0, 1)
0.fib(a, _) = a
n.fib(a, b) When n > 0 = (n-1).fib(b, a+b)

80.fib
"""
        measure {
            assertNoThrow {
                XCTAssertEqual(Expression.int(23416728348467685), try evaluate(code))
            }
        }
    }
}
