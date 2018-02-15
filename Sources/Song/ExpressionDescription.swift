extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch self {
            
        case let .error(value):
            return value
            
        case .unitValue:
            return "#"
            
        case let .booleanValue(value):
            return value ? "yes" : "no"
            
        case let .integerValue(value):
            return "\(value)"

        case let .floatValue(value):
            return "\(value)"

        case let .stringValue(value):
            return "'\(value)'"
            
        case let .isUnit(value):
            return "isUnit?(\(value))"

        case let .call(name: name, arguments: arguments):
            return "\(name)(\(arguments))"

        case let .pair(first, second):
            return "(\(first), \(second))"
            
        case let .first(value):
            return "first(\(value))"
            
        case let .second(value):
            return "second(\(value))"
            
        case let .closure(function, context):
            let contextList = contextDescription(context: context)
            return "[(\(contextList)) \(function)]"
            
        case let .let(name, binding, body):
            return "let (\(name) = \(binding)) { \(body) }"
            
        case let .variable(variable):
            return "V[\(variable)]"
            
        case let .subfunction(subfunction):
            return descriptionSubfunction(subfunction: subfunction)
            
        case let .callAnonymous(closure, arguments):
            return descriptionCallAnonymous(closure: closure, arguments: arguments)
            
        case let .conditional(condition, then, otherwise):
            return "\(condition) ? \(then) : \(otherwise)"

        case let .parameter(parameter):
            return parameter
        }
    }
    
    func descriptionSubfunction(subfunction: Subfunction) -> String {
        let parametersList = subfunction.patterns.map { "\($0)" }.joined(separator: ", ")
        if let funcName = subfunction.name {
            return "def \(funcName)(\(parametersList)) { \(subfunction.body) }"
        }
        return "λ(\(parametersList)) { \(subfunction.body) }"
    }
    
    func descriptionCallAnonymous(closure: Expression, arguments: [Expression]) -> String {
        var argumentStrings = Array<String>()
        for arg in arguments {
            argumentStrings.append("\(arg)")
        }
        let argumentsList = argumentStrings.joined(separator: ", ")
        return "\(closure)(\(argumentsList))"
    }
}
