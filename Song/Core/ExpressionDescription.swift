extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch self {
            
        case let .Error(value):
            return "<\(value)>"
            
        case .UnitValue:
            return "#"
            
        case let .BooleanValue(value):
            return value ? "yes" : "no"
            
        case let .IntegerValue(value):
            return "\(value)"
            
        case let .StringValue(value):
            return "'\(value)'"
            
        case let .IsUnit(value):
            return "isUnitValue(\(value))"
            
        case let .Plus(left, right):
            return "\(left) + \(right)"
            
        case let .Pair(first, second):
            return "(\(first), \(second))"
            
        case let .First(value):
            return "first(\(value))"
            
        case let .Second(value):
            return "second(\(value))"
            
        case let .Closure(function, context):
            let contextList = contextDescription(context)
            return "[(\(contextList)) \(function)]"
            
        case let .Let(name, binding, body):
            return "let (\(name) = \(binding)) { \(body) }"
            
        case let .Variable(variable):
            return "\(variable)"
            
        case let .Function(name, parameters, body):
            return descriptionFunction(name, parameters, body)
            
        case let .Call(closure, arguments):
            return descriptionCall(closure, arguments: arguments)
            
        case let .Conditional(condition, then, otherwise):
            return "if \(condition) then \(then) else \(otherwise) end"
        }
    }
    
    func descriptionFunction(name: String?, _ parameters: [String], _ body: Expression) -> String {
        let parametersList = parameters.joinWithSeparator(", ")
        if let funcName = name {
            return "def \(funcName)(\(parametersList)) { \(body) }"
        } else {
            return "λ(\(parametersList)) { \(body) }"
        }
    }
    
    func descriptionCall(closure: Expression, arguments: [Expression]) -> String {
        var argumentStrings = Array<String>()
        for arg in arguments {
            argumentStrings.append("\(arg)")
        }
        let argumentsList = argumentStrings.joinWithSeparator(", ")
        return "\(closure)(\(argumentsList))"
    }
}
