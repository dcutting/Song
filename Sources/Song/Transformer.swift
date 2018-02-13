import Syft

public enum TransformerError: Error {
    case unknown
    case notNumeric(String)
}

public func makeTransformer() -> Transformer<Expression> {
    let t = Transformer<Expression>()

    t.rule(["trueValue": .simple("")]) { _ in
        .booleanValue(true)
    }

    t.rule(["falseValue": .simple("")]) { _ in
        .booleanValue(false)
    }

    t.rule(["stringValue": .simple("s")]) {
        .stringValue(try $0.str("s"))
    }

    t.rule(["integerValue": .simple("i")]) {
        let i = try $0.str("i")
        guard let int = Int(i) else { throw TransformerError.notNumeric(i) }
        return .integerValue(int)
    }

    t.rule(["floatValue": .simple("f")]) {
        let f = try $0.str("f")
        guard let float = Double(f) else { throw TransformerError.notNumeric(f) }
        return .floatValue(float)
    }

    t.rule(["right": .simple("right"), "op": .simple("op")]) {
        let right = try $0.val("right")
        let op = try $0.str("op")
        return Expression.builtin(name: op, arguments: [right])
    }

    t.rule(["left": .simple("left"), "ops": .series("ops")]) {
        let left = try $0.val("left")
        var ops = try $0.vals("ops")
        guard ops.count > 0 else { return left }
        let first = ops.removeFirst()
        guard case .builtin(let name, var arguments) = first else {
            preconditionFailure("not a function call")
        }
        arguments.insert(left, at: 0)
        let firstFuncCall = Expression.builtin(name: name, arguments: arguments)
        return ops.reduce(firstFuncCall) { acc, next in
            guard case .builtin(let name, var arguments) = next else {
                preconditionFailure("not a function call")
            }
            arguments.insert(acc, at: 0)
            return Expression.builtin(name: name, arguments: arguments)
        }
    }

    return t
}
