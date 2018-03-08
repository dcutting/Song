public indirect enum EvaluationError: Error {

    case cannotEvaluate(Expression, EvaluationError)
    case symbolNotFound(String)
    case signatureMismatch([Expression])
    case notAClosure(Expression)
    case notABoolean(Expression)
    case notANumber(Expression)
    case notAList(Expression)
    case notAFunction(Expression)
    case patternsCannotBeFloats(Expression)
    case numericMismatch
    case emptyScope
    case notACharacter
}

extension EvaluationError: CustomStringConvertible {

    private static let tabIndent = 1

    public var description: String {
        return "Evaluation error\n" + format(error: self, indent: EvaluationError.tabIndent)
    }

    private func format(error: EvaluationError, indent: Int) -> String {
        var result: String
        switch error {
        case let .cannotEvaluate(expr, inner):
            return format(outer: expr, inner: inner, indent: indent)
        case .symbolNotFound(let symbol):
            result = "unknown symbol: \(symbol)"
        case .signatureMismatch(let arguments):
            result = "no pattern matches arguments: \(arguments)"
        case .notAClosure(let expr):
            result = "need a closure, not \(expr)"
        case .notABoolean(let expr):
            result = "need a boolean, not \(expr)"
        case .notANumber(let expr):
            result = "need a number, not \(expr)"
        case .notAList(let expr):
            result = "need a list, not \(expr)"
        case .notAFunction(let expr):
            result = "need a function, not \(expr)"
        case .patternsCannotBeFloats(let expr):
            result = "patterns cannot be floats: \(expr)"
        case .numericMismatch:
            result = "can only use integers here"
        case .emptyScope:
            result = "Do/End must contain at least one expression"
        case .notACharacter:
            result = "need a character"
        }
        return "💥  \(result)".indented(by: indent)
    }

    private func format(outer: Expression, inner: EvaluationError, indent: Int) -> String {
        let nextIndent = makeNextIndent(indent: indent)
        let innerFormatted = format(error: inner, indent: nextIndent)
        let outerFormatted = "↳ \(outer)".indented(by: indent)
        return outerFormatted + "\n" + innerFormatted
    }

    private func makeNextIndent(indent: Int) -> Int {
        return indent + EvaluationError.tabIndent
    }
}

private extension String {
    func indented(by: Int) -> String {
        guard by > 0 else { return self }
        return (" " + self).indented(by: by-1)
    }
}
