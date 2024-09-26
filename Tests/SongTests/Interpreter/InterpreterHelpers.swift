@testable import SongLang

func declareSubfunctions(_ functions: [Function]) throws -> Context {
    let exprs = functions.map { Expression.function($0) }
    return try declareSubfunctions(exprs)
}

func declareSubfunctions(_ functions: [Expression], in context: Context = .empty) throws -> Context {
    var context = context
    for function in functions {
        let result = try function.evaluate(context: context)
        if case .closure(let name, _, _) = result {
            if let name = name {
                context[name] = result
            }
        }
    }
    return context
}
