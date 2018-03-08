@testable import Song

func declareSubfunctions(_ subfunctions: [Function]) throws -> Context {
    let exprs = subfunctions.map { Expression.function($0) }
    return try declareSubfunctions(exprs)
}

func declareSubfunctions(_ subfunctions: [Expression], in context: Context = Context()) throws -> Context {
    var context = context
    for subfunction in subfunctions {
        let result = try subfunction.evaluate(context: context)
        if case .closure(let name, _, _) = result {
            if let name = name {
                context[name] = result
            }
        }
    }
    return context
}
