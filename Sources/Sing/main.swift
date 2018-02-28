import Foundation
import Utility
import Song
import Syft
import LineNoise

var interactive = true
var filename: String?
var verbose = false
let prompt = "> "
let incompletePrompt = ". "

func parse(arguments: [String]) throws {
    let argsParser = ArgumentParser(usage: "<options>", overview: "the Song functional language")
    let verboseArg: OptionArgument<Bool> = argsParser.add(option: "--verbose", shortName: "-v", kind: Bool.self, usage: "Verbose logging")
    let filenameArg = argsParser.add(positional: "filename", kind: String.self, optional: true)

    let arguments = Array(arguments.dropFirst())
    let parsedArguments = try argsParser.parse(arguments)

    verbose = parsedArguments.get(verboseArg) ?? false
    filename = parsedArguments.get(filenameArg)
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

var context: Context = [:]

func dumpContext() {
    print(context as AnyObject)
}

log("Song v0.2.0 🎵")

while (true) {

    guard let thisLine = getLine() else { break }

    if thisLine.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
        continue
    }

    lineNoise.addHistory(thisLine)

    if thisLine.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
        continue
    }
    if thisLine.trimmingCharacters(in: .whitespacesAndNewlines) == "?" {
        dumpContext()
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
                if case .closure(let function, _) = expression {
                    if case .subfunction(let subfunction) = function {
                        if let name = subfunction.name {
                            context = extendContext(context: context, name: name, value: expression, replacing: false)
                        }
                    }
                }
                if case .constant(let variable, let value) = expression {
                    if case .variable(let name) = variable {
                        context = extendContext(context: context, name: name, value: value, replacing: true)
                    }
                }
                switch expression {
                case .closure, .constant:
                    () // Do nothing.
                default:
                    log(expression)
                }
            } catch let error as EvaluationError {
                print(format(error: error))
                if verbose {
                    log()
                    log("Context:")
                    dumpContext()
                    log()
                    log("AST:")
                    dump(ast)
                    log()
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
        multilines.removeAll()
    }
}
log("👏")
