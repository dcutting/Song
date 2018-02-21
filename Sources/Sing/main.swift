import Foundation
import Song
import Syft

let verbose = true
let prompt = "➤ "

var lines: [String]?

var interactive = true
let args = CommandLine.arguments
if args.count > 1 {
    let filename = args[1]
    interactive = false

    let contents = try NSString(contentsOfFile: filename,
                                encoding: String.Encoding.utf8.rawValue)

    lines = [String]()
    contents.enumerateLines({ (line, stop) -> () in
        lines?.append(line)
    })
    if let line = lines?.first, line.hasPrefix("#!") {
        lines?.removeFirst()
    }
}

func getLine() -> String? {
    if let l = lines {
        if l.count > 0 {
            let line = lines?.removeFirst()
            return line
        }
        return nil
    }
    return readLine()
}

let parser = makeParser()
let transformer = makeTransformer()

func log(_ str: Any? = nil) {
    if interactive, let str = str {
        print(str)
    }
}

var context: Context = [:]

func dumpContext() {
    dump(context as AnyObject)
}

log("Song v0.1.0 🎵")

while (true) {
    if interactive {
        print(prompt, terminator: "")
    }
    guard let line = getLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { break }
    if line == "" {
        continue
    }
    if line == "?" {
        dumpContext()
        continue
    }
    let result = parser.parse(line)
    let (ist, remainder) = result
    if remainder.text.isEmpty {
        do {
            let ast = try transformer.transform(result)
            do {
                let expression = try ast.evaluate(context: context)
                if case .closure(let function, _) = expression {
                    if case .subfunction(let subfunction) = function {
                        if let name = subfunction.name {
                            // TODO: this extends the context with the same closure if the user enters the closure's name.
                            context = extendContext(context: context, name: name, value: expression, replacing: false)
                        }
                    }
                }
                if case .constant(let name, let value) = expression {
                    context = extendContext(context: context, name: name, value: value, replacing: true)
                }
                switch expression {
                case .closure, .constant:
                    () // Do nothing.
                default:
                    log(expression)
                }
            } catch {
                print(error)
                if verbose {
                    log()
                    log("Context:")
                    dumpContext()
                    log()
                    log("AST:")
                    dump(ast)
                    log()
                }
            }
        } catch {
            print("Internal transform error:")
            dump(error)
            log()
            log("Input: \(line)")
            log()
            log("IST:")
            log(makeReport(result: ist))
            log()
            log("\(remainder)")
            log()
        }
    } else {
        print("Syntax error at position \(remainder.index): \(remainder.text)")
        if verbose {
            log()
            log(makeReport(result: ist))
            log()
        }
    }
}
log("\n👏")
