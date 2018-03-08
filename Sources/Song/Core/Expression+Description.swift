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

        case let .listCons(head, tail):
            return "[\(head.map(String.init).joined(separator: ", "))|\(tail)]"

        case .ignore:
            return "_"

        case let .variable(variable):
            return "\(variable)"

        case let .subfunction(subfunction):
            return "\(subfunction)"

        case let .assign(name, value):
            return "\(name): \(value)"

        case let .closure(_, function, context):
            return "[(\(describeContext(context))) \(function)]"

        case let .scope(exprs):
            return "scope (" + exprs.map { "\($0)" }.joined(separator: ", ") + ")"

        case let .call(name, args):
            return "\(name)(\(describeArgs(args)))"

        case let .callAnon(closure, args):
            return "\(closure)(\(describeArgs(args)))"
        }
    }

    private func describeList(_ exprs: [Expression]) -> String {
        
        guard !exprs.isEmpty else { return "[]" }

        do {
            let value = try convertToString(characters: exprs)
            return "\"" + value.replacingOccurrences(of: "\"", with: "\\\"") + "\""
        } catch {
            return "[" + exprs.map(String.init).joined(separator: ", ") + "]"
        }
    }

    private func describeArgs(_ args: [Expression]) -> String {
        return args.map { "\($0)" }.joined(separator: ", ")
    }
}
