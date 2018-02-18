import XCTest

func assertNoThrow(_ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        XCTFail()
    }
}
