def _fib(n, a, b)
  return a if n == 0
  _fib(n-1, b, a+b)
end

def fib(n)
  _fib(n, 0, 1)
end

500.times do
  fib(80)
end
puts(fib(80))
