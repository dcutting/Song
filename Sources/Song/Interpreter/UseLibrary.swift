import Syft

let parser = makeParser()
let transformer = makeTransformer()

struct LoadError: Error {
    let remainder: String
}

public func evaluate(lines: [String], context: Context) throws -> Context {
    var context = context
    var multilines = [String]()
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
            throw LoadError(remainder: remainder.text)
        }
    }
    return context
}
