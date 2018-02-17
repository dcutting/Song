import Song

// [].length = 0
// [x|xs].length = 1 + xs.length

func integerList(values: [Int]) -> Expression {
    return Array(values.reversed()).reduce(Expression.unitValue) {
        Expression.pair(Expression.integerValue($1), $0)
    }
}

func evaluateSampleAST() {

    let listVar = Expression.variable("list")
    let isUnitValue = Expression.isUnit(listVar)
    let zero = Expression.integerValue(0)
    let one = Expression.integerValue(1)
    let second = Expression.second(listVar)
    let recursiveCall = Expression.callAnonymous(closure: Expression.variable("length"), arguments: [second])
    let otherwise = Expression.call(name: "+", arguments: [one, recursiveCall])
    let lengthBody = Expression.conditional(condition: isUnitValue, then: zero, otherwise: otherwise)
    let lengthSubfunction = Subfunction(name: "length", patterns: [Expression.variable("list")], when: Expression.booleanValue(true), body: lengthBody)
    let lengthFunc = Expression.subfunction(lengthSubfunction)
    let list = integerList(values: [1,2,3,4,3,2,1,2,2,4,4,1,2])
    let lengthCall = Expression.callAnonymous(closure: lengthFunc, arguments: [list])
    let result = try! lengthCall.evaluate()

    print(lengthCall)
    print(result)

    let lambdaSubfunction = Subfunction(name: nil, patterns: [], when: Expression.booleanValue(true), body: Expression.integerValue(5))
    let lambda = Expression.subfunction(lambdaSubfunction)
    let lambdaCall = Expression.callAnonymous(closure: Expression.variable("x"), arguments: [])
    let letExpr = Expression.let(name: "x", binding: lambda, body: lambdaCall)
    let lambdaResult = try! letExpr.evaluate();

    print(letExpr)
    print(lambdaResult)
}
