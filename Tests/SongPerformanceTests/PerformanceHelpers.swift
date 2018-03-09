import XCTest
import Song

func assertNoThrow(file: StaticString = #file, line: UInt = #line, _ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}

func evaluate(_ code: String) throws -> Expression? {
    let parser = makeParser()
    let transformer = makeTransformer()
    let lines = code.split(separator: "\n")
    var context = Context()
    var lastEval: Expression?
    for line in lines {
        let result = parser.parse(String(line))
        let expression = try transformer.transform(result)
        let evaluated = try expression.evaluate(context: context)
        if case .closure(let name, _, _) = evaluated {
            if let name = name {
                context = extendContext(context: context, name: name, value: evaluated)
            }
        }
        if case .assign(let variable, let value) = evaluated {
            if case .name(let name) = variable {
                context = extendContext(context: context, name: name, value: value)
            }
        }
        lastEval = evaluated
    }
    return lastEval
}
