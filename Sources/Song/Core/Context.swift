public typealias Context = [String: Expression]

public func extendContext(context: Context, name: String, value: Expression) -> Context {
    var extendedContext = context
    extendedContext[name] = value
    return extendedContext
}

func isEqual(lhsContext: Context, rhsContext: Context) -> Bool {
    guard Set(lhsContext.keys) == Set(rhsContext.keys) else { return false }
    for (key, value) in lhsContext {
        guard let rhsValue = rhsContext[key], value == rhsValue else { return false }
    }
    return true
}

func contextDescription(context: Context) -> String {
    var contextPairs = [String]()
    for (key, value) in context {
        contextPairs.append("\(key): \(value)")
    }
    return contextPairs.sorted().joined(separator: ", ")
}
