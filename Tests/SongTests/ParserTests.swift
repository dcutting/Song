import XCTest
import Song

class ParserTests: XCTestCase {

    func test_true() {
        let input = "yes"
        let actual = parse(input)
        let expected = Expression.booleanValue(true)
        XCTAssertEqual(expected, actual)
    }

    private func parse(_ line: String) -> Expression {
        let parser = makeParser()
        let transformer = makeTransformer()
        let result = parser.parse(line)
        return try! transformer.transform(result)
    }
}
