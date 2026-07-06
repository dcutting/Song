import XCTest
@testable import SongLang

class InterpreterTests: XCTestCase {
    func test_init_loadsStdlib() {
        _ = Interpreter(initialContext: .builtIns, interactive: false)
    }
}
