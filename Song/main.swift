print("Song")

// [].length = 0
// [x|xs].length = 1 + xs.length

func integerList(values: [Int]) -> Expression {
    return Array(values.reverse()).reduce(Expression.UnitValue) {
        Expression.Pair(Expression.IntegerValue($1), $0)
    }
}

let listVar = Expression.Variable("list")
let isUnitValue = Expression.IsUnit(listVar)
let zero = Expression.IntegerValue(0)
let one = Expression.IntegerValue(1)
let second = Expression.Second(listVar)
let recursiveCall = Expression.Call(closure: Expression.Variable("length"), arguments: [second])
let otherwise = Expression.Plus(one, recursiveCall)
let lengthBody = Expression.Conditional(condition: isUnitValue, then: zero, otherwise: otherwise)
let lengthFunc = Expression.Function(name: "length", parameters: ["list"], body: lengthBody)
let list = integerList([1,2,3,4,3,2,1,2,2,4,4,1,2])
let lengthCall = Expression.Call(closure: lengthFunc, arguments: [list])
let result = lengthCall.evaluate()

print(lengthCall)
print(result)

let lambda = Expression.Function(name: nil, parameters: [], body: Expression.IntegerValue(5))
let lambdaCall = Expression.Call(closure: Expression.Variable("x"), arguments: [])
let letExpr = Expression.Let(name: "x", binding: lambda, body: lambdaCall)
let lambdaResult = letExpr.evaluate();

println(letExpr)
println(lambdaResult)
