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
        "(4)()".ok()
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

        "4()".bad()
        "|x|x()".bad()
        "4.|x|x".bad()
    }
}
