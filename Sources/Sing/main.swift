import Foundation
import Utility
import Song
import Syft
import LineNoise

var verbose = false
var filename: String?
var scriptArgs = [String]()

var interactive = true
let prompt = "> "
let incompletePrompt = ". "

func parse(arguments: [String]) throws {
    let argsParser = ArgumentParser(usage: "<options> [filename]", overview: "the Song functional language")
    let verboseArg: OptionArgument<Bool> = argsParser.add(option: "--verbose", shortName: "-v", kind: Bool.self, usage: "Verbose logging")
    let scriptArgsArg = argsParser.add(positional: "filename", kind: [String].self, optional: true, strategy: .remaining, usage: "Song script to run and arguments to pass to it")


    let arguments = Array(arguments.dropFirst())
    let parsedArguments = try argsParser.parse(arguments)

    verbose = parsedArguments.get(verboseArg) ?? false
    scriptArgs = parsedArguments.get(scriptArgsArg) ?? []
    filename = scriptArgs.first
}

#if Xcode
    let builtWithXcode = true
#else
    let builtWithXcode = false
#endif

let lineNoise = LineNoise()
lineNoise.preserveHistoryEdits = true

var lines: [String]?
var lineNumber = 0
var multilines = [String]()

do {
    let args = CommandLine.arguments
    try parse(arguments: args)
} catch {
    print(error)
    exit(1)
}

if let filename = filename {
    interactive = false

    let contents = try NSString(contentsOfFile: filename,
                                encoding: String.Encoding.utf8.rawValue)

    lines = [String]()
    contents.enumerateLines({ (line, stop) -> () in
        lines?.append("\(line)\n")
    })
    if let line = lines?.first, line.hasPrefix("#!") {
        lines?.removeFirst()
    }
}

func getLine() -> String? {
    if let l = lines {
        if l.count > 0 {
            let line = lines?.removeFirst()
            lineNumber += 1
            return line
        }
        return nil
    }
    while (true) {
        do {
            let nextPrompt = multilines.isEmpty ? prompt : incompletePrompt
            let line: String?
            if !builtWithXcode && lineNoise.mode == .supportedTTY {
                line = try lineNoise.getLine(prompt: nextPrompt)
                print()
            } else {
                print(nextPrompt, terminator: "")
                line = readLine(strippingNewline: true)
            }
            return line
        } catch LinenoiseError.CTRL_C {
            print("^C")
        } catch {
            print(error)
            exit(1)
        }
    }
}

let parser = makeParser()
let transformer = makeTransformer()

func log(_ str: Any? = nil) {
    if interactive, let str = str {
        print(str)
    }
}

let songArgs = scriptArgs.map { Expression.string($0) }
var context: Context = ["args": .list(songArgs)]

func dumpContext() {
    print(context as AnyObject)
}

log("Song v0.6.0 🎵")

while (true) {

    guard let thisLine = getLine() else { break }

    if thisLine.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
        continue
    }

    if interactive {
        lineNoise.addHistory(thisLine)
    }

    if thisLine.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
        continue
    }
    if thisLine.trimmingCharacters(in: .whitespacesAndNewlines) == "?" {
        dumpContext()
        continue
    }
    if thisLine.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("?del ") {
        var tokens = thisLine.components(separatedBy: .whitespaces)
        guard tokens.count > 1 else {
            print("Try \"?del SYMBOL [...]\"")
            continue
        }
        tokens.removeFirst()
        for token in tokens {
            context.removeValue(forKey: String(token))
        }
        continue
    }

    multilines.append(thisLine)

    let line = multilines.joined(separator: "\n")

    let result = parser.parse(line)
    let (ist, remainder) = result
    if verbose {
        print("  \(line), \(remainder), \(multilines), \(parsedLastCharacter)")
    }
    if remainder.text.isEmpty {
        multilines.removeAll()
        do {
            let ast = try transformer.transform(result)
            do {
                let expression = try ast.evaluate(context: context)
                if case .closure(let name, _, _) = expression {
                    if let name = name {
                        context = extendContext(context: context, name: name, value: expression)
                    }
                }
                if case .assign(let variable, let value) = expression {
                    if case .name(let name) = variable {
                        context = extendContext(context: context, name: name, value: value)
                    }
                }
                switch expression {
                case .closure, .assign:
                    () // Do nothing.
                default:
                    log(expression)
                }
            } catch let error as EvaluationError {
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
                if !interactive {
                    exit(1)
                }
            } catch {
                print("Fatal error: \(error)")
                exit(1)
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
            if !interactive {
                exit(1)
            }
        }
    } else if !parsedLastCharacter {
        let remainder = remainder.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if interactive {
            print("💥  syntax error: \(remainder)")
        } else {
            print("💥  syntax error on line \(lineNumber): \(remainder)")
        }
        if verbose {
            log()
            log(makeReport(result: ist))
            log()
        }
        if !interactive {
            exit(1)
        }
        multilines.removeAll()
    }
}
log("👏")
