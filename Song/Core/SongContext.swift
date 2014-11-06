import Foundation

public typealias SongContext = [String: Expression]

func contextDescription(context: SongContext) -> String {
    var contextPairs = Array<String>()
    for (key, value) in context {
        contextPairs.append("\(key) = \(value)")
    }
    contextPairs.sort { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
    return ", ".join(contextPairs)
}

func extendContext(context: SongContext, #name: String, #value: Expression) -> SongContext {
    var extendedContext = context
    extendedContext[name] = value
    return extendedContext
}

func extendContext(context: SongContext, #parameters: [String], #arguments: [ExpressionLike], #callingContext: SongContext) -> SongContext {
    var extendedContext = context
    for (var i = 0; i < parameters.count; i++) {
        let name = parameters[i]
        let value = arguments[i] as Expression
        let evaluatedValue = value.evaluate(callingContext)
        extendedContext = extendContext(extendedContext, name: name, value: evaluatedValue)
    }
    return extendedContext
}
