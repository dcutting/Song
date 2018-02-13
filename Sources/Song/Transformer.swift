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

    t.rule(["expression": .simple("e")]) {
        return try $0.val("e")
    }

    t.rule(["listItem": .simple("item")]) {
        return try $0.val("item")
    }

    t.rule(["variable": .simple("v")]) {
        let v = try $0.str("v")
        return Expression.variable(v)
    }

    t.rule(["arg": .simple("arg")]) {
        return try $0.val("arg")
    }

    t.rule(["funcName": .simple("funcName"), "args": .series("args")]) {
        let funcName = try $0.str("funcName")
        let args = try $0.vals("args")
        return Expression.builtin(name: funcName, arguments: args)
    }

    t.rule(["subject": .simple("subject"), "calls": .series("calls")]) {
        let calls = try $0.vals("calls")
        let call = calls.first!
        let subject = try $0.val("subject")
        return Expression.call(closure: call, arguments: [subject])
    }

    t.rule(["FUNC": .simple("funcName"), "body": .simple("body"), "defunSubject": .simple("subject")]) {
        let funcName = try $0.str("funcName")
//        let subject = try $0.val("subject")
        let body = try $0.val("body")
        return Expression.function(name: funcName, parameters: [], body: body)
    }

    t.rule(["list": .series("items")]) {
        let items = try $0.vals("items").reversed()
        return items.reduce(Expression.unitValue) { acc, item in
            return Expression.pair(item, acc)
        }
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
