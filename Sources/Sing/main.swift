import Song
import Syft

print("Song v0.1.0 🎵")

let verbose = true
let prompt = "➤ "

let parser = makeParser()
let transformer = makeTransformer()

func log(_ str: String = "") {
    guard verbose else { return }
    print(str)
}

var context: Context = [:]
while (true) {
    print(prompt, terminator: "")
    guard let line = readLine(strippingNewline: true) else { break }
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
                print(expression)
            } catch {
                print(error)
                log()
                log("Context: \(context)")
                log("AST: \(ast)")
                log()
            }
        } catch {
            print("Transform error")
            log()
            log(makeReport(result: ist))
            log()
            log("\(error)")
        }
    } else {
        print("Syntax error at position \(remainder.index): \(remainder.text)")
        log()
        log(makeReport(result: ist))
        log()
    }
}
print("\n👏")
