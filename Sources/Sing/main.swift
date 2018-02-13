import Song
import Syft

print("Song v0.1.0 🎵")

let verbose = true
let prompt = "🎤 "

let parser = makeParser()
let transformer = makeTransformer()

func log(_ str: String = "") {
    guard verbose else { return }
    print(str)
}

while (true) {
    var context: Context = [:]
    do {
        log()
        print(prompt, terminator: "")
        guard let line = readLine(strippingNewline: true) else { break }
        let result = parser.parse(line)
        let (ist, _) = result
        log()
        log(makeReport(result: ist))
        let ast = try transformer.transform(result)
        log()
        log(">>> \(ast)")
        log()
        let expression = ast.evaluate(context: context)
        if case .function(let name, _, _) = expression {
            if let name = name {
                context[name] = expression
            }
        }
        print(expression)
    } catch Syft.TransformerError<Expression>.unexpectedRemainder(let remainder) {
        log()
        print("Syntax error at \(remainder.index): \(remainder.text)")
    } catch {
        log()
        print("ERROR: \(error)")
    }
}
print("\n👏")
