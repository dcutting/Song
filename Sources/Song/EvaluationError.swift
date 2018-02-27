public indirect enum EvaluationError: Error {
    case cannotEvaluate(Expression, EvaluationError)
    case symbolNotFound(String)
    case signatureMismatch
    case notABoolean(Expression)
    case notANumber(Expression)
    case notAList(Expression)
    case notAFunction(Expression)
    case patternsCannotBeFloats(Expression)
    case emptyScope
    case notACharacter
}

public func format(error: EvaluationError) -> String {
    return "Evaluation error\n" + format(error: error, indent: 1)
}

private func format(error: EvaluationError, indent: Int) -> String {
    switch error {
    case let .cannotEvaluate(expr, inner):
        return format(scope: expr, inner: inner, indent: indent)
    case .symbolNotFound(let symbol):
        return "💥  unknown symbol: \(symbol)".indented(by: indent)
    case .signatureMismatch:
        return "💥  no matching pattern found".indented(by: indent)
    case .notABoolean(let expr):
        return "💥  need a boolean, not \(expr)".indented(by: indent)
    case .notANumber(let expr):
        return "💥  need a number, not \(expr)".indented(by: indent)
    case .notAList(let expr):
        return "💥  need a list, not \(expr)".indented(by: indent)
    case .notAFunction(let expr):
        return "💥  need a function, not \(expr)".indented(by: indent)
    case .patternsCannotBeFloats(let expr):
        return "💥  patterns cannot be floats: \(expr)".indented(by: indent)
    case .emptyScope:
        return "💥  Do/End cannot be empty".indented(by: indent)
    case .notACharacter:
        return "💥  need a character".indented(by: indent)
    }
}

private func format(scope: Expression, inner: EvaluationError, indent: Int) -> String {
    let nextIndent = makeNextIndent(indent: indent)
    let innerFormatted = format(error: inner, indent: nextIndent)
    let scopeFormatted = "↳ \(scope)".indented(by: indent)
    return scopeFormatted + "\n" + innerFormatted
}

private func makeNextIndent(indent: Int) -> Int {
    let tabIndent = 1
    return indent + tabIndent
}

extension String {
    func indented(by: Int) -> String {
        guard by > 0 else { return self }
        return (" " + self).indented(by: by-1)
    }
}
