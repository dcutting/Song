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

    t.rule(["left": .simple("left"), "ops": .simple("")]) {
        try $0.val("left")
    }

    t.rule(["right": .simple("right"), "op": .simple("op")]) {
        let right = try $0.val("right")
        Expression.plus(<#T##Expression#>, right)
    }

//    t.rule(["left": .simple("left"), "ops": .series("ops")]) {
//
//    }

    return t
}
