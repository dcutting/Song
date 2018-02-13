extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch self {
            
        case let .error(value):
            return "<\(value)>"
            
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
            return "isUnitValue(\(value))"

        case let .builtin(name: name, arguments: arguments):
            return "\(name)(\(arguments))"

        case let .plus(left, right):
            return "\(left) + \(right)"
            
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
            return "\(variable)"
            
        case let .function(name, parameters, body):
            return descriptionFunction(name: name, parameters, body)
            
        case let .call(closure, arguments):
            return descriptionCall(closure: closure, arguments: arguments)
            
        case let .conditional(condition, then, otherwise):
            return "if \(condition) then \(then) else \(otherwise) end"
        }
    }
    
    func descriptionFunction(name: String?, _ parameters: [String], _ body: Expression) -> String {
        let parametersList = parameters.joined(separator: ", ")
        if let funcName = name {
            return "def \(funcName)(\(parametersList)) { \(body) }"
        }
        return "λ(\(parametersList)) { \(body) }"
    }
    
    func descriptionCall(closure: Expression, arguments: [Expression]) -> String {
        var argumentStrings = Array<String>()
        for arg in arguments {
            argumentStrings.append("\(arg)")
        }
        let argumentsList = argumentStrings.joined(separator: ", ")
        return "\(closure)(\(argumentsList))"
    }
}
