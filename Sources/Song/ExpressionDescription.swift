extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch self {
            
        case let .booleanValue(value):
            return value ? "yes" : "no"
            
        case let .integerValue(value):
            return "\(value)"

        case let .floatValue(value):
            return "\(value)"

        case let .stringValue(value):
            let escaped = value.replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(escaped)\""
            
        case let .list(exprs):
            let descriptions = exprs.map { "\($0)" }
            let joined = descriptions.joined(separator: ", ")
            return "[\(joined)]"

        case let .listConstructor(head, tail):
            let descriptions = head.map { "\($0)" }
            let heads = descriptions.joined(separator: ", ")
            return "[\(heads)|\(tail)]"

        case let .variable(variable):
            return "\(variable)"

        case let .subfunction(subfunction):
            return descriptionSubfunction(subfunction: subfunction)

        case let .constant(name, value):
            return "\(name) = \(value)"

        case let .closure(function, context):
            let contextList = contextDescription(context: context)
            return "[(\(contextList)) \(function)]"

        case let .call(name: name, arguments: arguments):
            return descriptionCall(name: name, arguments: arguments)

        case let .callAnonymous(closure, arguments):
            return descriptionCallAnonymous(closure: closure, arguments: arguments)
        }
    }
    
    func descriptionSubfunction(subfunction: Subfunction) -> String {
        let parametersList = subfunction.patterns.map { "\($0)" }.joined(separator: ", ")
        if let funcName = subfunction.name {
            return "\(funcName)(\(parametersList)) when \(subfunction.when) = \(subfunction.body)"
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
