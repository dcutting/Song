println("Song")

// [].length = 0
// [x|xs].length = 1 + xs.length

let listVar = SongExpression.SongVariable("list")
let isUnit = SongExpression.SongIsUnit(listVar)
let zero = SongExpression.SongInteger(0)
let one = SongExpression.SongInteger(1)
let second = SongExpression.SongSecond(listVar)
let recursiveCall = SongExpression.SongCall(closure: SongExpression.SongVariable("length"), arguments: [second])
let otherwise = SongExpression.SongPlus(one, recursiveCall)
let lengthBody = SongExpression.SongIf(condition: isUnit, then: zero, otherwise: otherwise)
let lengthFunc = SongExpression.SongFunction(name: "length", parameters: ["list"], body: lengthBody)
let lengthClosure = lengthFunc.evaluate()
let listB = SongExpression.SongPair(SongExpression.SongInteger(9), SongExpression.SongUnit)
let list = SongExpression.SongPair(SongExpression.SongInteger(5), listB)
let lengthCall = SongExpression.SongCall(closure: lengthClosure, arguments: [list])
let result = lengthCall.evaluate()

println(lengthCall)
println(result)
