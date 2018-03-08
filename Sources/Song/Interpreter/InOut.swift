import Basic

public protocol StdIn {
    func get() -> String?
}

public protocol StdOut {
    func put(_ output: String)
}

public class DefaultStdIn: StdIn {
    public func get() -> String? {
        return readLine()
    }
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
