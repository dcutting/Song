import XCTest
@testable import SongLang

extension String {
    func makes(_ expected: SongLang.Expression, file: StaticString = #filePath, line: UInt = #line) {
        assertNoThrow(file: file, line: line) {
            let actual = try parse(self)
            XCTAssertEqual(expected, actual, file: file, line: line)
        }
    }

    func fails(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try parse(self), "should not parse", file: file, line: line)
    }

    private func parse(_ line: String) throws -> SongLang.Expression {
        let parser = SongParser().parser
        let transformer = makeTransformer()
        let result = parser.parse(line)
        return try transformer.transform(result)
    }
}
