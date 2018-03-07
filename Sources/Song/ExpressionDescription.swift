extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch self {
            
        case let .bool(value):
            return value ? "Yes" : "No"
            
        case let .numberValue(value):
            return "\(value)"

        case let .character(value):
            let string = "\(value)"
            let escaped = string.replacingOccurrences(of: "\'", with: "\\\'")
            return "'\(escaped)'"

        case let .list(exprs):
            if exprs.isEmpty {
                return "[]"
            }
            do {
                let value = try convertToString(characters: exprs)
                let escaped = value.replacingOccurrences(of: "\"", with: "\\\"")
                return "\"\(escaped)\""
            } catch {
                let descriptions = exprs.map { "\($0)" }
                let joined = descriptions.joined(separator: ", ")
                return "[\(joined)]"
            }

        case let .listConstructor(head, tail):
            let descriptions = head.map { "\($0)" }
            let heads = descriptions.joined(separator: ", ")
            return "[\(heads)|\(tail)]"

        case .anyVariable:
            return "_"

        case let .variable(variable):
            return "\(variable)"

        case let .subfunction(subfunction):
            return descriptionSubfunction(subfunction: subfunction)

        case let .constant(name, value):
            return "\(name): \(value)"

        case let .closure(_, function, context):
            let contextList = contextDescription(context: context)
            return "[(\(contextList)) \(function)]"

        case let .call(name: name, arguments: arguments):
            return descriptionCall(name: name, arguments: arguments)

        case let .callAnonymous(closure, arguments):
            return descriptionCallAnonymous(closure: closure, arguments: arguments)

        case let .scope(expressions):
            return "scope (" + expressions.map { "\($0)" }.joined(separator: ", ") + ")"
        }
    }

    func descriptionSubfunction(subfunction: Subfunction) -> String {
        let parametersList = subfunction.patterns.map { "\($0)" }.joined(separator: ", ")
        if let funcName = subfunction.name {
            return "\(funcName)(\(parametersList)) When \(subfunction.when) = \(subfunction.body)"
        }
        return "λ(\(parametersList)) = \(subfunction.body)"
    }

    func descriptionCall(name: String, arguments: [Expression]) -> String {
        return "\(name)(\(description(arguments: arguments)))"
    }

    func descriptionCallAnonymous(closure: Expression, arguments: [Expression]) -> String {
        return "\(closure)(\(description(arguments: arguments)))"
    }

    private func description(arguments: [Expression]) -> String {
        return arguments.map { "\($0)" }.joined(separator: ", ")
    }
}
