import Foundation
import Song
import Syft

print("Song v0.1.0 🎵")

let verbose = true
let prompt = "➤ "

let parser = makeParser()
let transformer = makeTransformer()

func log(_ str: String = "") {
    print(str)
}

var context: Context = [:]

func dumpContext() {
    print(context as AnyObject)
}

while (true) {
    print(prompt, terminator: "")
    guard let line = readLine(strippingNewline: true) else { break }
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
                            context[name] = expression
                        }
                    }
                }
                if case .constant(let name, let value) = expression {
                    context[name] = value
                }
                switch expression {
                case .unitValue, .closure, .constant:
                    () // Do nothing.
                default:
                    print(expression)
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
            print("Internal transform error: \(error)")
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
print("\n👏")
