#!/usr/bin/env swift

func fib(_ n: Int64, _ a: Int64, _ b: Int64) -> Int64 {
  if n == 0 {
    return a
  }
  return fib(n-1, b, a+b)
}

func fib(_ n: Int64) -> Int64 {
  return fib(n, 0, 1)
}

for _ in (1...500) {
  _ = fib(80)
}
print(fib(80))
