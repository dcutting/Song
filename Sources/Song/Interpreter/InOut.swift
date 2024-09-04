import Foundation

public protocol StdIn {
    func get() -> String?
}

public protocol StdOut {
    func put(_ output: String)
}

public class DefaultStdIn: StdIn {
    init() {}
    public func get() -> String? {
        return readLine()
    }
}

public class DefaultStdOut: StdOut {
    init() {}
    public func put(_ output: String) {
        print(output, terminator: "")
    }
}

public class DefaultStdErr: StdOut {
    init() {}
    public func put(_ output: String) {
        guard let data = output.data(using: .utf8) else { return }
        try? FileHandle.standardError.write(contentsOf: data)
    }
}
