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

func isEqual(lhsContext: Context, rhsContext: Context) -> Bool {
    guard Set(lhsContext.keys) == Set(rhsContext.keys) else { return false }
    for (key, value) in lhsContext {
        guard let rhsValue = rhsContext[key], value == rhsValue else { return false }
    }
    return true
}
