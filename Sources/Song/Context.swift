public typealias Context = [String: Expression]

func contextDescription(context: Context) -> String {
    var contextPairs = Array<String>()
    for (key, value) in context {
        contextPairs.append("\(key) = \(value)")
    }
    return contextPairs.sorted().joined(separator: ", ")
}

func extendContext(context: Context, name: String, value: Expression) -> Context {
    var extendedContext = context
    extendedContext[name] = value
    return extendedContext
}

func extendContext(context: Context, parameters: [Expression], arguments: [Expression], callingContext: Context) throws -> Context {
    var extendedContext = context
    for i in 0..<parameters.count {
        let param = parameters[i]
        guard case .variable(let name) = param else {
            preconditionFailure("Expected a parameter: \(param)")
        }
        let value = arguments[i]
        let evaluatedValue = try value.evaluate(context: callingContext)
        extendedContext = extendContext(context: extendedContext, name: name, value: evaluatedValue)
    }
    return extendedContext
}
