public typealias Context = [String: [Expression]]

func contextDescription(context: Context) -> String {
    var contextPairs = Array<String>()
    for (key, value) in context {
        contextPairs.append("\(key) = \(value)")
    }
    return contextPairs.sorted().joined(separator: ", ")
}

public func extendContext(context: Context, name: String, value: Expression, replacing: Bool) -> Context {
    var extendedContext = context
    var group = extendedContext[name, default: []]
    if replacing {
        group.removeAll()
    }
    group.append(value)
    extendedContext[name] = group
    return extendedContext
}

func extendContext(context: Context, parameters: [Expression], arguments: [Expression], callingContext: Context) throws -> Context {
    guard parameters.count <= arguments.count else { throw EvaluationError.insufficientArguments }
    guard arguments.count <= parameters.count else { throw EvaluationError.tooManyArguments }
    var extendedContext = context
    for i in 0..<parameters.count {
        let param = parameters[i]
        if case .variable(let name) = param {
            let value = arguments[i]
            let evaluatedValue = try value.evaluate(context: callingContext)
            extendedContext = extendContext(context: extendedContext, name: name, value: evaluatedValue, replacing: true)
        }
    }
    return extendedContext
}
