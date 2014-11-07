public typealias Context = [String: Expression]

func contextDescription(context: Context) -> String {
    var contextPairs = Array<String>()
    for (key, value) in context {
        contextPairs.append("\(key) = \(value)")
    }
    return ", ".join(sorted(contextPairs))
}

func extendContext(context: Context, #name: String, #value: Expression) -> Context {
    var extendedContext = context
    extendedContext[name] = value
    return extendedContext
}

func extendContext(context: Context, #parameters: [String], #arguments: [ExpressionLike], #callingContext: Context) -> Context {
    var extendedContext = context
    for (var i = 0; i < parameters.count; i++) {
        let name = parameters[i]
        let value = arguments[i] as Expression
        let evaluatedValue = value.evaluate(callingContext)
        extendedContext = extendContext(extendedContext, name: name, value: evaluatedValue)
    }
    return extendedContext
}
