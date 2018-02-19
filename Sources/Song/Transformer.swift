import Syft

public enum TransformerError: Error {
    case unknown
    case notNumeric(String)
    case noFunctionCalls
}

public func makeTransformer() -> Transformer<Expression> {
    let t = Transformer<Expression>()

    t.rule(["trueValue": .simple("")]) { _ in
        .booleanValue(true)
    }

    t.rule(["falseValue": .simple("")]) { _ in
        .booleanValue(false)
    }

    t.rule(["stringValue": .simple("s")]) { _ in
    throw TransformerError.notNumeric("4")
//    .stringValue(try $0.str("s"))
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
        return Expression.call(name: op, arguments: [right])
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
        return Expression.call(name: funcName, arguments: args)
    }

    t.rule(["funcName": .simple("funcName")]) {
        let funcName = try $0.str("funcName")
        return Expression.call(name: funcName, arguments: [])
    }

    t.rule(["subject": .simple("subject"), "calls": .series("calls")]) {
        let subject = try $0.val("subject")
        var calls = try $0.vals("calls")
        guard calls.count > 0 else { throw TransformerError.noFunctionCalls }
        let firstCall = calls.removeFirst()
        guard case let .call(call) = firstCall else { throw TransformerError.noFunctionCalls }
        let arguments = [subject] + call.arguments
        let firstFuncCall = Expression.call(name: call.name, arguments: arguments)
        return calls.reduce(firstFuncCall) { acc, next in
            guard case .call(let name, var arguments) = next else {
                preconditionFailure("not a function call")
            }
            arguments.insert(acc, at: 0)
            return Expression.call(name: name, arguments: arguments)
        }
    }

    t.rule(["param": .simple("param")]) {
        let param = try $0.str("param")
        return Expression.variable(param)
    }

    t.rule(["funcName": .simple("funcName"), "body": .simple("body"), "guard": .simple("guard"), "subject": .simple("subject")]) {
        Expression.subfunction(try transformFunction(args: $0))
    }

    t.rule(["funcName": .simple("funcName"), "body": .simple("body"), "guard": .simple("guard"), "params": .series("params")]) {
        Expression.subfunction(try transformFunction(args: $0))
    }

    t.rule(["funcName": .simple("funcName"), "body": .simple("body"), "guard": .simple("guard"), "subject": .simple("subject"), "params": .series("params")]) {
        Expression.subfunction(try transformFunction(args: $0))
    }

    t.rule(["lambdaBody": .simple("body"), "params": .series("params")]) {
        let subfunction = try transformFunction(args: $0)
        let closure = Expression.subfunction(subfunction)
        return closure
    }

    t.rule(["lambda": .simple("lambda")]) {
        try $0.val("lambda")
    }

    func transformFunction(args: TransformerReducerArguments<Expression>) throws -> Subfunction {
        var funcName: String?
        do {
            funcName = try args.str("funcName")
        } catch {}
        var params = [Expression]()
        do {
            params = try args.vals("params")
        } catch {}
        do {
            let subject = try args.val("subject")
            params.insert(subject, at: 0)
        } catch {}
        var when = Expression.booleanValue(true)
        do {
            when = try args.val("guard")
        } catch {}
        let body = try args.val("body")
        let subfunction = Subfunction(name: funcName, patterns: params, when: when, body: body)
        return subfunction
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
        guard case .call(let name, var arguments) = first else {
            preconditionFailure("not a function call")
        }
        arguments.insert(left, at: 0)
        let firstFuncCall = Expression.call(name: name, arguments: arguments)
        return ops.reduce(firstFuncCall) { acc, next in
            guard case .call(let name, var arguments) = next else {
                preconditionFailure("not a function call")
            }
            arguments.insert(acc, at: 0)
            return Expression.call(name: name, arguments: arguments)
        }
    }

    t.rule(["body": .simple("body"), "variable": .simple("name")]) {
        let name = try $0.str("name")
        let body = try $0.val("body")
        return Expression.constant(name: name, value: body)
    }

    t.rule(["let": .simple("let")]) {
        try $0.val("let")
    }

    return t
}
