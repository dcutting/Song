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
