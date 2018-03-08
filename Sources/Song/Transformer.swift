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
        .listCons(try $0.vals("heads"), try $0.val("tail"))
    }

    // Literals.

    t.rule(["true": .simple("")]) { _ in
        .bool(true)
    }

    t.rule(["false": .simple("")]) { _ in
        .bool(false)
    }

    t.rule(["integer": .simple("i")]) {
        let i = try $0.str("i")
        guard let int = IntType(i) else { throw SongTransformError.notNumeric(i) }
        return .int(int)
    }

    t.rule(["float": .simple("f")]) {
        let f = try $0.str("f")
        guard let float = FloatType(f) else { throw SongTransformError.notNumeric(f) }
        return .float(float)
    }

    t.rule(["character": .simple("c")]) {
        return .char(Character(unescape(try $0.str("c"))))
    }

    t.rule(["string": .simple("s")]) {
        return .string(unescape(try $0.str("s")))
    }

    func unescape(_ value: String) -> String {
        var string = value
        string = string.replacingOccurrences(of: "\\\\", with: "\\")
        string = string.replacingOccurrences(of: "\\\"", with: "\"")
        string = string.replacingOccurrences(of: "\\\'", with: "'")
        return string
    }

    // Expressions.

    t.rule(["right": .simple("right"), "op": .simple("op")]) {
        .call(try $0.str("op"), [try $0.val("right")])
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
        let firstFuncCall = Expression.call(name, arguments)
        return try ops.reduce(firstFuncCall) { acc, next in
            guard case .call(let name, var arguments) = next else {
                throw SongTransformError.notAFunctionCall
            }
            arguments.insert(acc, at: 0)
            return Expression.call(name, arguments)
        }
    }

    // Atoms.

    t.rule(["variableName": .simple("v")]) {
        let v = try $0.str("v")
        return v == "_" ? .ignore : .variable(v)
    }

    t.rule(["functionName": .simple("name")]) {
        .call(try $0.str("name"), [])
    }

    // Function calls.

    t.rule(["args": .series("args")]) {
        .list(try $0.vals("args"))
    }

    t.rule(["functionName": .simple("name"), "args": .series("args")]) {
        .call(try $0.str("name"), try $0.vals("args"))
    }

    t.rule(["param": .simple("param")]) {
        try $0.val("param")
    }

    t.rule(["params": .series("params"), "body": .simple("body")]) {
        .subfunction(Subfunction(name: nil, patterns: try $0.vals("params"), when: .bool(true), body: try $0.val("body")))
    }

    t.rule(["lambda": .simple("lambda")]) {
        try $0.val("lambda")
    }

    t.rule(["head": .simple("head"), "nameCall": .simple("call")]) {
        let head = try $0.val("head")
        guard case let .call(name, arguments) = try $0.val("call") else { throw SongTransformError.notAFunctionCall }
        return .call(name, [head] + arguments)
    }

    t.rule(["head": .simple("head"), "anonCall": .simple("expr")]) {
        let head = try $0.val("head")
        let expr = try $0.val("expr")
        return .callAnon(expr, [head])
    }

    t.rule(["head": .simple("head"), "anonCall": .simple("expr"), "args": .series("args")]) {
        let head = try $0.val("head")
        let expr = try $0.val("expr")
        let args = try $0.vals("args")
        return .callAnon(.callAnon(expr, [head]), args)
    }

    t.rule(["anonCall": .simple("anon"), "args": .series("args")]) {
        let args = try $0.vals("args")
        return .callAnon(try $0.val("anon"), args)
    }

    t.rule(["anonCall": .simple("args")]) {
        guard case .list(let args) = try $0.val("args") else { throw SongTransformError.unknown }
        let dummy = Expression.bool(false)
        return .callAnon(dummy, args)
    }

    t.rule(["nameCall": .simple("call")]) {
        try $0.val("call")
    }

    t.rule(["trailCalls": .series("calls")]) {
        try reduce(try $0.vals("calls"))
    }

    t.rule(["dotCall": .series("calls")]) {
        try reduce(try $0.vals("calls"))
    }

    t.rule(["scopeStatement": .simple("statement")]) {
        try $0.val("statement")
    }

    // Function declarations.

    t.rule(["subject": .simple("subject"), "functionName": .simple("name"), "guard": .simple("guard"), "body": .simple("body")]) {
        .subfunction(try transformFunction(args: $0))
    }

    t.rule(["subject": .simple("subject"), "functionName": .simple("name"), "params": .series("params"), "guard": .simple("guard"), "body": .simple("body")]) {
        .subfunction(try transformFunction(args: $0))
    }

    t.rule(["functionName": .simple("name"), "body": .simple("body"), "guard": .simple("guard"), "params": .series("params")]) {
        .subfunction(try transformFunction(args: $0))
    }

    // Constants.

    t.rule(["constBody": .simple("body"), "variable": .simple("var")]) {
        .assign(variable: try $0.val("var"), value: try $0.val("body"))
    }

    // Scopes.

    t.rule(["scopeItems": .series("scopeItems")]) {
        .scope(try $0.vals("scopeItems"))
    }

    // Terms.

    t.rule(["wrapped": .simple("e")]) {
        try $0.val("e")
    }

    return t
}

func reduce(_ calls: [Expression]) throws -> Expression {
    guard calls.count > 0 else { throw SongTransformError.unknown }
    var calls = calls
    var result = calls.removeFirst()
    try calls.forEach { call in
        switch call {
        case let .callAnon(_, args):
            result = .callAnon(result, args)
        case let .call(name, args):
            result = .call(name, [result] + args)
        default:
            throw SongTransformError.notAFunctionCall
        }
    }
    return result
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
    var when = Expression.bool(true)
    do {
        when = try args.val("guard")
    } catch {}
    let body = try args.val("body")
    return Subfunction(name: name, patterns: params, when: when, body: body)
}
