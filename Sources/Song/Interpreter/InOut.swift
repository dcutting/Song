import Basic

public protocol StdIn {
    func get() -> String?
}

public class DefaultStdIn: StdIn {
    public func get() -> String? {
        return readLine()
    }
}

public class StubStdIn: StdIn {

    private var stubbed: String?

    public init(_ stubbed: String?) {
        self.stubbed = stubbed
    }

    public func get() -> String? {
        return stubbed
    }
}

public protocol StdOut {
    func put(_ output: String)
}

public class DefaultStdOut: StdOut {
    public func put(_ output: String) {
        return print(output, terminator: "")
    }
}

public class DefaultStdErr: StdOut {
    public func put(_ output: String) {
        stderrStream <<< output
        stderrStream.flush()
    }
}

public class SpyStdOut: StdOut {

    public var actual: String?

    public init() {}

    public func put(_ output: String) {
        actual = output
    }
}
