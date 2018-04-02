extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch self {
            
        case let .bool(value):
            return value ? "Yes" : "No"
            
        case let .number(value):
            return "\(value)"

        case let .char(value):
            return "'" + "\(value)".replacingOccurrences(of: "\'", with: "\\\'") + "'"

        case let .list(exprs):
            return describeList(exprs)

        case let .cons(head, tail):
            return "[" + head.map(String.init).joined(separator: ", ") + "|\(tail)]"

        case .ignore:
            return "_"

        case let .name(variable):
            return "\(variable)"

        case let .function(function):
            return "\(function)"

        case let .assign(name, value):
            return "\(name): \(value)"

        case let .closure(_, function, context):
            return "[(" + describeContext(context) + ") \(function)]"

        case let .scope(exprs):
            return "scope (" + exprs.map { "\($0)" }.joined(separator: ", ") + ")"

        case let .call(name, args):
            return "\(name)(\(describeArgs(args)))"

        case let .eval(closure, args):
            return "\(closure)(\(describeArgs(args)))"

        case let .tailCall(name, args):
            return "\(name)(\(describeArgs(args)))"
        }
    }

    private func describeList(_ exprs: [Expression]) -> String {
        
        if exprs.isEmpty { return "[]" }

        var result: String
        do {
            let value = try convertToString(characters: exprs)
            result = "\"" + value.replacingOccurrences(of: "\"", with: "\\\"") + "\""
        } catch {
            result = "[" + exprs.map(String.init).joined(separator: ", ") + "]"
        }
        return result
    }

    private func describeArgs(_ args: [Expression]) -> String {
        return args.map(String.init).joined(separator: ", ")
    }
}
