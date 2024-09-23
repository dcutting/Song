public typealias Context = [String: Expression]

public func extendContext(context: Context, name: String, value: Expression) -> Context {
    var extendedContext = context
    extendedContext[name] = value
    return extendedContext
}

public func extend(context: Context, with: Context) -> Context {
    return context.merging(with) { l, r in r }
}

func isEqual(lhsContext: Context, rhsContext: Context) -> Bool {
    guard Set(lhsContext.keys) == Set(rhsContext.keys) else { return false }
    for (key, value) in lhsContext {
        guard let rhsValue = rhsContext[key], value == rhsValue else { return false }
    }
    return true
}

func describeContext(_ context: Context) -> String {
    var contextPairs = [String]()
    for (key, value) in context {
        contextPairs.append("\(key): \(value)")
    }
    return contextPairs.sorted().joined(separator: ", ")
}

public extension Context {
    func extend(with context: Context) -> Context {
        SongLang.extend(context: self, with: context)
    }
}
