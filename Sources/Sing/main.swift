import Song

print("Song v0.1.0 🎵")

let prompt = "🎤 "

let parser = makeParser()
let transformer = makeTransformer()

while (true) {
    do {
        print(prompt, terminator: "")
        guard let line = readLine(strippingNewline: true) else { break }
        let ist = parser.parse(line)
        print(ist)
        let ast = try transformer.transform(ist)
        print(ast)
        print(ast.evaluate())
    } catch {
        print(error)
    }
}
print("\n🙇‍♀️")
