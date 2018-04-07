import Syft

public struct InterpreterError: Error {
    let remainder: String
}

public struct InterpreterResult {
    let output: InterpreterOutput
    let state: InterpreterState
}

public enum InterpreterOutput {
    case expression(Expression)
    case output(String)
    case error(Error)
    case none
}

public enum InterpreterState {
    case ok
    case waiting
}

public class Interpreter {

    public var context: Context
    private let interactive: Bool
    private var multilines = [String]()
    private let parser = makeParser()
    private let transformer = makeTransformer()

    public init(context: Context, interactive: Bool) {
        self.context = context
        self.interactive = interactive
    }

    public func finish() -> String? {
        if interactive || multilines.isEmpty {
            return nil
        }
        return multilines.joined()
    }

    private var state: InterpreterState {
        return multilines.isEmpty ? .ok : .waiting
    }

    private func makeResult(_ output: InterpreterOutput) -> InterpreterResult {
        return InterpreterResult(output: output, state: state)
    }

    public func interpret(line: String) throws -> InterpreterResult {

        if line.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            line.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
            return makeResult(.none)
        }

        if line.trimmingCharacters(in: .whitespacesAndNewlines) == "?" {
            return makeResult(.output(describeContext(context)))
        }

        if line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("?del ") {
            var tokens = line.components(separatedBy: .whitespaces)
            guard tokens.count > 1 else {
                return makeResult(.output("Try \"?del SYMBOL [...]\""))
            }
            tokens.removeFirst()
            for token in tokens {
                context.removeValue(forKey: String(token))
            }
            return makeResult(.none)
        }

        multilines.append(line)
        let joinedLine = multilines.joined(separator: "\n")
        let result = parser.parse(joinedLine)
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
            return makeResult(.expression(expression))
        } else if !parsedLastCharacter {
            return makeResult(.error(InterpreterError(remainder: remainder.text)))
        }
        return makeResult(.none)
    }
}
