import XCTest
@testable import Song

extension String {

    func makes(_ expected: Expression, file: StaticString = #file, line: UInt = #line) {
        assertNoThrow(file: file, line: line) {
            let actual = try parse(self)
            XCTAssertEqual(expected, actual, file: file, line: line)
        }
    }

    func fails(file: StaticString = #file, line: UInt = #line) {
        XCTAssertThrowsError(try parse(self), "should not parse", file: file, line: line)
    }

    private func parse(_ line: String) throws -> Expression {
        let parser = makeParser()
        let transformer = makeTransformer()
        let result = parser.parse(line)
        return try transformer.transform(result)
    }
}
