import XCTest

func assertNoThrow(file: StaticString = #filePath, line: UInt = #line, _ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}
