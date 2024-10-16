import Syft

public struct InterpreterError: Error {
    let remainder: String
}

public struct InterpreterResult {
    public let output: InterpreterOutput
    public let state: InterpreterState
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
    private var resetContext: Context
    private let interactive: Bool
    private var multilines = [String]()
    private let parser = SongParser().parser
    private let transformer = makeTransformer()

    public init(initialContext: Context, interactive: Bool) {
        self.context = initialContext
        self.resetContext = initialContext
        self.interactive = interactive
        readStdLib()
        self.resetContext = context
    }
    
    private func readStdLib() {
        for child in Stdlib().children {
            if let file = child as? File {
                if let data = file.contents {
                    if let line = String(data: data, encoding: String.Encoding.utf8) {
                        let lines = line.split(separator: "\n").map { String($0) }
                        do {
                            for line in lines {
                                _ = try interpret(line: line)
                            }
                        } catch {
                            preconditionFailure("Could not load stdlib '\(file.filename)': \(error)")
                        }
                    }
                }
            }
        }
    }
    
    public func reset() {
        context = resetContext
        multilines = []
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
            return makeResult(.output(describe(context: context)))
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
                if let name {
                    context = context.extend(name: name, value: expression)
                }
            }
            if case .assign(let variable, let value) = expression {
                if case .name(let name) = variable {
                    context = context.extend(name: name, value: value)
                }
            }
            return makeResult(.expression(expression))
        } else if !parsedLastCharacter {
            multilines.removeAll()
            return makeResult(.error(InterpreterError(remainder: remainder.text)))
        }
        return makeResult(.none)
    }
}
