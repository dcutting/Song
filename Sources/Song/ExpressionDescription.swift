extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch self {
            
        case .unitValue:
            return "#"
            
        case let .booleanValue(value):
            return value ? "yes" : "no"
            
        case let .integerValue(value):
            return "\(value)"

        case let .floatValue(value):
            return "\(value)"

        case let .stringValue(value):
            return "\"\(value)\""
            
        case let .isUnit(value):
            return "isUnit?(\(value))"

        case let .call(name: name, arguments: arguments):
            return descriptionCall(name: name, arguments: arguments)

        case let .pair(first, second):
            return "(\(first), \(second))"
            
        case let .first(value):
            return "first(\(value))"
            
        case let .second(value):
            return "second(\(value))"
            
        case let .let(name, binding, body):
            return "let (\(name) = \(binding)) { \(body) }"
            
        case let .variable(variable):
            return "\(variable)"

        case let .constant(name, value):
            return "\(name) = \(value)"

        case let .subfunction(subfunction):
            return descriptionSubfunction(subfunction: subfunction)

        case let .closure(function, context):
            let contextList = contextDescription(context: context)
            return "[(\(contextList)) \(function)]"

        case let .callAnonymous(closure, arguments):
            return descriptionCallAnonymous(closure: closure, arguments: arguments)
            
        case let .conditional(condition, then, otherwise):
            return "\(condition) ? \(then) : \(otherwise)"
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
