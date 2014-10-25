[].length = 0
[x|xs].length = 1 + xs.length
 
def length(list)
  if isaunit(list)
    0
  else
    1 + length(snd(list))

isaunit
snd
 
+
recursion
 
func testAddition() {
  let integerPlus = SongExpression.SongVariable("x")
  let addition = SongExpression.SongPlus(integer, integerPlus)
  let result = addition.evaluate(
}
