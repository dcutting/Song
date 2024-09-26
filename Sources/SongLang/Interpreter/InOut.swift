import Foundation

@MainActor let _stdIn: StdIn = DefaultStdIn()
@MainActor let _stdOut: StdOut = DefaultStdOut()
@MainActor let _stdErr: StdOut = DefaultStdErr()

@MainActor func evaluateIn(arguments: [Expression], context: Context) throws -> Expression {
    let output = try arguments.formattedString(context: context)
    _stdOut.put(output)
    let line = _stdIn.get() ?? ""
    return .string(line)
}

@MainActor func evaluateOut(arguments: [Expression], context: Context) throws -> Expression {
    let output = try arguments.formattedString(context: context)
    _stdOut.put(output + "\n")
    return .string(output)
}

@MainActor func evaluateErr(arguments: [Expression], context: Context) throws -> Expression {
    let output = try arguments.formattedString(context: context)
    _stdErr.put(output + "\n")
    return .string(output)
}

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
