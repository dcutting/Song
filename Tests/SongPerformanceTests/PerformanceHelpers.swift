import XCTest
import SongLang

func assertNoThrow(file: StaticString = #filePath, line: UInt = #line, _ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}

func evaluate(_ code: String) throws -> SongLang.Expression? {
    let parser = makeParser()
    let transformer = makeTransformer()
    let lines = code.split(separator: "\n")
    var context = rootContext
    var lastEval: SongLang.Expression?
    for line in lines {
        let result = parser.parse(String(line))
        let expression = try transformer.transform(result)
        let evaluated = try expression.evaluate(context: context)
        if case .closure(let name, _, _) = evaluated {
            if let name = name {
                context = context.extend(name: name, value: evaluated)
            }
        }
        if case .assign(let variable, let value) = evaluated {
            if case .name(let name) = variable {
                context = context.extend(name: name, value: value)
            }
        }
        lastEval = evaluated
    }
    return lastEval
}
