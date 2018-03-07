import XCTest
@testable import Song

func assertNoThrow(file: StaticString = #file, line: UInt = #line, _ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}

func declareSubfunctions(_ subfunctions: [Subfunction]) throws -> Context {
    return try declareSubfunctions(subfunctions.map { Expression.subfunction($0) })
}

func declareSubfunctions(_ subfunctions: [Expression]) throws -> Context {
    var context = Context()
    for subfunction in subfunctions {
        let result = try subfunction.evaluate(context: context)
        if case .closure(let name, _, _) = result {
            if let name = name {
                context[name] = result
            }
        }
    }
    return context
}

extension String {

    func ok(file: StaticString = #file, line: UInt = #line) {
        let parser = makeParser()
        let (_, remainder) = parser.parse(self)
        if !remainder.text.isEmpty {
            XCTFail(remainder.text, file: file, line: line)
        }
    }

    func bad(file: StaticString = #file, line: UInt = #line) {
        let parser = makeParser()
        let (_, remainder) = parser.parse(self)
        if remainder.text.isEmpty {
            XCTFail("should not parse", file: file, line: line)
        }
    }
}

extension String {

    func becomes(_ expected: Expression, file: StaticString = #file, line: UInt = #line) {
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
