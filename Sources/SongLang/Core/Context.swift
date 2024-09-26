public typealias Context = [String: Expression]

public extension Context {
    func extend(name: String, value: Expression) -> Context {
        extend(with: [name: value])
    }

    func extend(with context: Context) -> Context {
        merging(context) { _, r in r }
    }
}

public func describe(context: Context) -> String {
    context.map { "\($0): \($1)" }.sorted().joined(separator: ", ")
}

public extension Context {
    static let empty = Self()
    
    static let interactive = builtIns
    
    static let script = builtIns.extend(with: io)

    static let builtIns = BuiltInName.allCases.reduce(into: Context()) { context, builtIn in
        context[builtIn.keyword] = .builtIn(builtIn)
    }

    static let io: Context = [:]
//        "in": .builtIn(evaluateIn),
//        "out": .builtIn(evaluateOut),
//        "err": .builtIn(evaluateErr),
}
