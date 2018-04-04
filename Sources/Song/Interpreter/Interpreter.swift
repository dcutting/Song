import Syft

let parser = makeParser()
let transformer = makeTransformer()

struct InterpreterError: Error {
    let remainder: String
}

public class Interpreter {

    public private(set) var context: Context
    private var multilines = [String]()

    public init(context: Context) {
        self.context = context
    }

    public func evaluate(line: String) throws -> Expression? {
        return try evaluate(lines: [line])
    }

    public func evaluate(lines: [String]) throws -> Expression? {

        var finalExpression: Expression?
        for thisLine in lines {

            guard
                thisLine.trimmingCharacters(in: .whitespacesAndNewlines) != "",
                !thisLine.trimmingCharacters(in: .whitespaces).hasPrefix("#")
            else { continue }

            multilines.append(thisLine)
            let line = multilines.joined(separator: "\n")

            let result = parser.parse(line)
            let (_, remainder) = result
            if remainder.text.isEmpty {
                multilines.removeAll()
                let ast = try transformer.transform(result)
                let expression = try ast.evaluate(context: context)
                if case .closure(let name, _, _) = expression {
                    if let name = name {
                        context = extendContext(context: context, name: name, value: expression)
                    }
                }
                if case .assign(let variable, let value) = expression {
                    if case .name(let name) = variable {
                        context = extendContext(context: context, name: name, value: value)
                    }
                }
            } else if !parsedLastCharacter {
                throw InterpreterError(remainder: remainder.text)
            }
        }
        return finalExpression
    }
}
