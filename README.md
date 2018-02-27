[![Travis](https://travis-ci.org/dcutting/Song.svg)](https://travis-ci.org/dcutting/Song)
[![Coverage Status](https://coveralls.io/repos/github/dcutting/Song/badge.svg)](https://coveralls.io/github/dcutting/Song)

Song is **alpha** quality and is not intended for production use.

# Song

Song is a terse, functional programming language.

Here's a program that calculates Fibonacci numbers:

```
0.fib = 0
1.fib = 1
n.fib = (n-2).fib + (n-1).fib

7.fib
# 13
```

Song has no loops and no if statements. Instead, you use recursion and pattern matching. There are no reference types, everything is a value.

Here are some more complex examples:

```
```

## Using Song

You can use [Mint](https://github.com/yonaskolb/Mint) to install Song:

```
mint install dcutting/Song
```

You can use the Song REPL from the command-line to play around:

```
$ song
Song v0.1.0 🎵
>
```

Use CTRL-D to exit the REPL.

You can also run Song scripts:

```
song fib.sg
```

And you can put a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) at the top of your script to run it directly (don't forget to `chmod` your script to make it executable):

```
#!/usr/bin/env song

0.fib = 0
1.fib = 1
n.fib = (n-2).fib + (n-1).fib

out(7.fib)
```

## Types

### Booleans

The boolean literals are `Yes` and `No`. Song has the standard logical operators:

```
Yes And No
# No

No Or Yes
# Yes

Not No
# Yes
```

### Numbers

Song numbers can be integers or floats. You can do arithmetic with them as you'd expect:

```
5 + 4 * -2
# -3

3.4 / 2.0
# 1.7
```

If you mix integers and floats in your arithmetic, you'll always get a float result:

```
5 + 1.2
# 6.2
```

And if you use operators that don't guarantee an integer result, you'll always get a float:

```
5 / 2
# 2.5
```

If you want to do integer division, you can use `5 Div 2` and `5 Mod 2` (but using those with floats will cause an error).

You can compare numbers:

```
4 Eq 4 # Yes
4 Neq 4 # No
4 > 2 # Yes
4 < 2 # No
4 >= 4 # Yes
4 <= 3 # No
```

### Lists

Lists are how you combine simple values into more complex values. Items can be different types:

```
[] # Empty list
[1, 2, 3]
[Yes, 1, 2.3]
```

You can nest lists:

```
[[1, 2], [3, 4]]
```

You can concatenate two lists with the `+` operator:

```
[1, 2] + [3, 4]
# [1, 2, 3, 4]
```

You can also use the "list constructor" syntax to insert items at the beginning of a list:

```
x = [3, 4]
[1,2|x]
# [1, 2, 3, 4]
```

### Characters

Individual character literals look like this:

```
'A'
'$'
'\''
'\\'
```

You can't do much with characters by themselves, but when you put them into a list Song interprets them as strings:

```
['h', 'e', 'l', 'l', 'o']
# "hello"
```

And you can use the string literal syntax as shorthand to create strings:

```
"hello"
# equivalent to ['h', 'e', 'l', 'l', 'o']
```

## Variables

You can assign values to variables:

```
x = 5
y = 9
z = x < y
```

## Functions

Functions can be written and called using two equivalent syntaxes: "free" or "subject".

Free functions have all parameters and arguments in parentheses after the function name.

Subject functions have the first argument appearing before the function name with dot notation.

These two function declarations are equivalent:

```
inc(x) = x+1
x.inc = x+1
```

Note that in the subject syntax, the parentheses are optional if there's only one parameter.

These two function calls are also equivalent:

```
inc(1)
1.inc
```

Again, the parentheses are optional for the subject syntax.

You can mix the different syntaxes for declaring/calling functions:

```
inc(x) = x+1

5.inc
# 6
```

Functions that take more than one parameter look like this:

```
plus(x, y) = x+y
x.plus(y) = x+y

plus(3, 4)
# 7
2.plus(3)
# 5
```

### Patterns

Song uses pattern matching to decide which function to call, and as a way of binding arguments to parameters.

You've seen simple patterns already:

```
x.inc = x+1
```

This function will match any argument passed to it, and bind it to the variable `x`.

You've also seen literal patterns:

```
1.fib = 1
```

This will only match calls where the argument is the value `1`:

```
1.fib
# 1

(2-1).fib
# 1

2.fib
# error, no match found
```

To do more powerful computation, you can use the list constructor syntax to destructure lists into a head and tail:

```
[x|xs].head = x

[5, 6, 7].head
# 5
```

In cases like this where you only care about part of the pattern, you can use underscores to ignore other matches:

```
[x|_].head = x

[5, 6, 7].head
# 5
```

If you want to match more than just the head, you can add more parameters:

```
[x,y|xs].second = y

[1, 2, 3].second
# 2
```

You can now write functions that process entire lists. This function calculates the length of a list:

```
[].length = 0
[_|xs].length = 1 + xs.length
```

Patterns can be nested as needed:

```
[[], []].zip = []
[[x|xs], [y|ys]].zip = [[x, y]] + [xs, ys].zip

[[1, 2, 3], ['a', 'b', 'c']].zip
# [[1, 'a'], [2, 'b'], [3, 'c']]
```

### When

Sometimes you need a bit more discrimination than pure patterns can provide. The `When` clause applies an additional constraint on a function that a caller must match.

This function takes a list of numbers and returns those that are more than some argument:

```
[].moreThan(_) = []
[x|xs].moreThan(n) When x > n = [x|xs.moreThan(n)]
[_|xs].moreThan(n) = xs.moreThan(n)
```

Pattern matching is performed in the order the function is declared. The first match found will always proceed, so you need to declare your more specific cases above your more general cases.

## Lambdas

Not all functions need names. Lambdas let you make anonymous functions that can be passed around as values to other functions.

This function `apply` expects a function `f` that takes one argument. It then calls that function using the other value it's been given:

```
x.apply(f) = f(x)

5.apply(|a| a*2)
# 10
```

Note the lambda syntax uses pipes `|` to specify parameters. Lambdas can have as many parameters as you like, although they must have at least one.

Lambdas don't just have to be passed as arguments. They can also live on their own in a variable:

```
double = |x| x*2

double(5)
# 10
```

Or you could store them in a variable, and use that variable when a lambda is expected:

```
x.apply(f) = f(x)

double = |x| x*2

5.apply(double)
# 10
```

As with named functions, you can call lambdas using free or subject syntax:

```
double = |x| x*2

double(5)
# 10

5.double
# 10
```

## `Do`/`End` scopes

Sometimes you want to break your functions into a few statements to make them easier to read. You can do this with scopes:

```
[].sort = []
[x|xs].sort = Do
  left = xs.select(|k| k < x)
  right = xs.select(|k| k >= x)
  left.sort + [x] + right.sort
End
```

Scopes evaluate each expression in their body, but only return the result of the last one.

You can also write scopes on one line using commas:

```
x.inc = Do y = x+1, y End
```

## Input and output

You can print things to stdout using the `out()` built-in function:

```
out("hello", " world ", 99)
# "hello world 99"
```

Song cannot currently read input, so you'll need to include all data in your script.
