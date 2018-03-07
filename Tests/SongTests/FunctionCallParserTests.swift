import XCTest
import Song

class FunctionCallParserTests: XCTestCase {

    func test() {
        "1.inc".ok()
        "x.inc".ok()
        "1.inc()".ok()
        "1.inc.foo".ok()
        "1.inc.foo()".ok()
        "1.inc().foo".ok()
        "1.inc().foo()".ok()
        "foo().inc".ok()
        "foo()().inc".ok()
        "foo().bar()".ok()
        "(5).foo.bar".ok()
        "(5.foo).bar".ok()
        "(5.foo)(4)".ok()
        "5.(foo).bar".ok()
        "5.(foo.bar)".ok()
        "(||5)()".ok()
        "(|x|x)(1)".ok()
        "(|x|x)(1)(2)".ok()
        "(|x|x)(1)(2).foo".ok()
        "1.(|x|x)".ok()
        "(foo)()".ok()
        "(foo())()".ok()
        "foo()".ok()
        "foo(bar)".ok()
        "foo(bar())".ok()
        "foo(bar(baz()))".ok()
        "foo(bar()())".ok()
        "foo(bar(baz()())())".ok()
        "foo(bar(baz()())()).inc".ok()
        "foo(|x|x)".ok()
        "foo((|x|x))".ok()
        "foo(|x|x,|y|y)".ok()
        "foo(|x|x.foo(bar()())(),1)".ok()

        "1.foo()".ok() //          # .call(foo, 1)
        "1.foo(2)(3)".ok() //      # .anon(.call(foo, 1, 2), 3)
        "1.foo(2)(3).bar".ok() //  # .call(bar, .anon(.call(foo, 1, 2), 3))
        "1.(foo)(2)(3)".ok() //    # .anon(.anon(.var(foo), 1), 2)
        "(1.foo)(2)".ok() //       # .anon(.call(foo, 1), 2)
        "1.foo()(2)".ok() //       # .anon(.call(foo, 1), 2)
        "1.(foo())(2)".ok() //     # .anon(.anon(.call(foo), 1) ,2)
        "1.foo(3)(4)".ok() //      # .anon(.call(foo, 1, 3), 4)
        "1.(foo(3))(2)".ok() //    # .anon(.anon(.call(foo, 3), 1), 2)
        "foo.bar.baz".ok() //      # .call(baz, .call(bar, .var(foo)))
        "foo(1).foo(2)(3).bar".ok() // # .call(bar, .anon(.call(foo, .call(foo, 1), 2), 3))
        "(foo).bar".ok() //        # .call(bar, .var(foo))
        "(foo(2)).bar".ok() //    # .call(bar, .call(foo, 2))
        "1.(foo.bar).bar".ok() //  # .call(bar, .anon(.call(bar, .var(foo)), 1))
        "(foo.bar).bar".ok() //    # .call(bar, .call(bar, .var(foo)))
        "foo(bar())".ok() //       # .call(foo, .call(bar))
        "foo(4.bar)".ok() //       # .call(foo, .call(bar, 4))
        "foo(4.bar())".ok() //     # .call(foo, .call(bar, 4))
        "foo().bar".ok() //        # .call(bar, .call(foo))
        "foo()().bar".ok() //      # .call(bar, .anon(.call(foo)))
        "foo.bar()()".ok() //      # .anon(.call(bar, .var(foo)))
        "foo(4.foo(bar(2))).(foo()().bar).bar(3)".ok() //  # .call(bar, ... , 3)
        "(|x|x)(1)".ok() //        # .anon(|x|x, 1)
        "(|x|x).foo(1)".ok() //    # .call(foo, |x|x, 1)
        "(x)(1)(2,3).bar".ok() //  # .call(bar, .anon(.anon(x, 1), 2, 3))
        "(|x|x)(1)(2,3).bar".ok() //    # .call(bar, .anon(.anon(|x|x, 1), 2, 3))
        "(|x|x)().bar".ok() //     # .call(bar, .anon(|x|x))
        "1.(|x|x)".ok() //         # .anon(|x|x, 1)
        "1.(|x|x)()".ok() //       # .anon(.anon(|x|x, 1))
        "foo().(|x|x)()".ok() //   # .anon(.anon(|x|x, .call(foo)))
        "foo.bar(|x|x).baz".ok() //# .call(baz, .call(bar, .var(foo), |x|x))
        "bar(|x|x)".ok() //        # .call(bar, |x|x)
        "bar(|x|foo(x))".ok() //   # .call(bar, |x|foo(x))
        "bar((|x|x))".ok() //      # .call(bar, |x|x)
        "x.foo(2)(3,4)(5).bar(6)(7)".ok() //
        "x.foo(2)(3).bar".ok() //  # .call(bar, .call(foo, 1, 2))
        "1.foo".ok() //            # .call(foo, 1)
        "lessthan(5)(4)".ok() //   # .anon(.call(lessThan, 5), 4)
        "(foo)()".ok() //
        "(1+2).foo".ok() //

        "4()".bad()
        "4.|x|x".bad()
        "(4)()".bad()
    }
}
