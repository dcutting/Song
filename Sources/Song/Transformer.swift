import Foundation
import Syft

public enum SongTransformError: Error {
    case unknown
    case notNumeric(String)
    case notAFunction
    case notAFunctionCall
}

public func makeTransformer() -> Transformer<Expression> {
    let t = Transformer<Expression>()

    // Lists.

    t.rule(["item": .simple("item")]) {
        try $0.val("item")
    }

    t.rule(["list": .series("items")]) {
        .list(try $0.vals("items"))
    }

    t.rule(["heads": .series("heads"), "tail": .simple("tail")]) {
        .listConstructor(try $0.vals("heads"), try $0.val("tail"))
    }

    // Literals.

    t.rule(["true": .simple("")]) { _ in
        .booleanValue(true)
    }

    t.rule(["false": .simple("")]) { _ in
        .booleanValue(false)
    }

    t.rule(["integer": .simple("i")]) {
        let i = try $0.str("i")
        guard let int = IntType(i) else { throw SongTransformError.notNumeric(i) }
        return .integerValue(int)
    }

    t.rule(["float": .simple("f")]) {
        let f = try $0.str("f")
        guard let float = FloatType(f) else { throw SongTransformError.notNumeric(f) }
        return .floatValue(float)
    }

    t.rule(["string": .simple("s")]) {
        var value = try $0.str("s")
        value = value.replacingOccurrences(of: "\\\\", with: "\\")
        value = value.replacingOccurrences(of: "\\\"", with: "\"")
        return .stringValue(value)
    }

    // Expressions.

    t.rule(["right": .simple("right"), "op": .simple("op")]) {
        .call(name: try $0.str("op"), arguments: [try $0.val("right")])
    }

    t.rule(["left": .simple("left"), "ops": .series("ops")]) {
        let left = try $0.val("left")
        var ops = try $0.vals("ops")
        guard ops.count > 0 else { return left }
        let first = ops.removeFirst()
        guard case .call(let name, var arguments) = first else {
            throw SongTransformError.notAFunctionCall
        }
        arguments.insert(left, at: 0)
        let firstFuncCall = Expression.call(name: name, arguments: arguments)
        return try ops.reduce(firstFuncCall) { acc, next in
            guard case .call(let name, var arguments) = next else {
                throw SongTransformError.notAFunctionCall
            }
            arguments.insert(acc, at: 0)
            return Expression.call(name: name, arguments: arguments)
        }
    }

    // Atoms.

    t.rule(["variableName": .simple("v")]) {
        let v = try $0.str("v")
        return v == "_" ? .anyVariable : .variable(v)
    }

    t.rule(["functionName": .simple("name")]) {
        .call(name: try $0.str("name"), arguments: [])
    }

    // Function calls.

    t.rule(["arg": .simple("arg")]) {
        try $0.val("arg")
    }

    t.rule(["functionName": .simple("name"), "args": .series("args")]) {
        .call(name: try $0.str("name"), arguments: try $0.vals("args"))
    }

    t.rule(["subject": .simple("subject"), "calls": .series("calls")]) {
        let subject = try $0.val("subject")
        var calls = try $0.vals("calls")
        guard calls.count > 0 else { throw SongTransformError.notAFunction }
        let firstCall = calls.removeFirst()
        guard case let .call(call) = firstCall else { throw SongTransformError.notAFunction }
        let arguments = [subject] + call.arguments
        let firstFuncCall = Expression.call(name: call.name, arguments: arguments)
        return try calls.reduce(firstFuncCall) { acc, next in
            guard case .call(let name, var arguments) = next else {
                throw SongTransformError.notAFunction
            }
            arguments.insert(acc, at: 0)
            return Expression.call(name: name, arguments: arguments)
        }
    }

    // Function declarations.

    t.rule(["param": .simple("param")]) {
        try $0.val("param")
    }

    t.rule(["functionName": .simple("name"), "body": .simple("body"), "guard": .simple("guard"), "subject": .simple("subject")]) {
        .subfunction(try transformFunction(args: $0))
    }

    t.rule(["functionName": .simple("name"), "body": .simple("body"), "guard": .simple("guard"), "params": .series("params")]) {
        .subfunction(try transformFunction(args: $0))
    }

    t.rule(["subject": .simple("subject"), "functionName": .simple("name"), "body": .simple("body"), "guard": .simple("guard"), "params": .series("params")]) {
        .subfunction(try transformFunction(args: $0))
    }

    // Lambdas.

    t.rule(["lambdaBody": .simple("body"), "params": .series("params")]) {
        .subfunction(try transformFunction(args: $0))
    }

    // Constants.

    t.rule(["constBody": .simple("body"), "variable": .simple("var")]) {
        .constant(variable: try $0.val("var"), value: try $0.val("body"))
    }

    // Terms.

    t.rule(["wrapped": .simple("e")]) {
        try $0.val("e")
    }

    return t
}

func transformFunction(args: TransformerReducerArguments<Expression>) throws -> Subfunction {
    var name: String?
    do {
        name = try args.str("name")
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
    return Subfunction(name: name, patterns: params, when: when, body: body)
}
