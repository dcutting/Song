extension Expression: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .bool(value):
            value ? "Yes" : "No"
        case let .number(value):
            "\(value)"
        case let .char(value):
            "'" + "\(value)".replacingOccurrences(of: "\'", with: "\\\'") + "'"
        case let .list(exprs):
            describeList(exprs)
        case let .cons(head, tail):
            "[" + head.map(String.init).joined(separator: ", ") + "|\(tail)]"
        case .unnamed:
            "_"
        case let .name(variable):
            variable
        case let .function(function):
            "\(function)"
        case let .assign(name, value):
            "\(name): \(value)"
        case let .closure(_, function, _):
            "\(function)"
        case let .scope(exprs):
            "scope (" + exprs.map { "\($0)" }.joined(separator: ", ") + ")"
        case let .call(name, args):
            "\(name)(\(describeArgs(args)))"
        case let .eval(closure, args):
            "\(closure)(\(describeArgs(args)))"
        case let .tailEval(closure, args):
            "\(closure)(\(describeArgs(args)))"
        case .builtIn(let builtIn):
            "\(builtIn)"
        }
    }

    private func describeList(_ exprs: [Expression]) -> String {
        if exprs.isEmpty { return "[]" }
        do {
            let value = try toString(characters: exprs)
            return "\"" + value.replacingOccurrences(of: "\"", with: "\\\"") + "\""
        } catch {
            return "[" + exprs.map(String.init).joined(separator: ", ") + "]"
        }
    }

    private func describeArgs(_ args: [Expression]) -> String {
        return args.map(String.init).joined(separator: ", ")
    }
}
