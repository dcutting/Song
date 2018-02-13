import Song
import Syft

print("Song v0.1.0 🎵")

let prompt = "🎤 "

let parser = makeParser()
let transformer = makeTransformer()

while (true) {
    do {
        print()
        print(prompt, terminator: "")
        guard let line = readLine(strippingNewline: true) else { break }
        let result = parser.parse(line)
        let (ist, _) = result
        print()
        print(makeReport(result: ist))
        let ast = try transformer.transform(result)
        print()
        print(">>> \(ast)")
        print()
        print(ast.evaluate())
    } catch {
        print()
        print("ERROR: \(error)")
    }
}
print("\n👏")
