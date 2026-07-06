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
    let parser = SongParser()
    let lines = code.split(separator: "\n")
    var context = Context.builtIns
    var lastEval: SongLang.Expression?
    for line in lines {
        let expression = try parser.parse(String(line))
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
