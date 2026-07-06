import Foundation
import ArgumentParser
import SongLang
import LineNoise

private let prompt = "> "
private let incompletePrompt = ". "

struct Song: ParsableCommand {
    @Flag(name: .shortAndLong, help: "Include verbose debugging output.")
    var verbose = false
    
    @Argument(help: "The filename of a Song script to run.")
    var filename: String?
    
    @Argument(help: "Arguments that will be passed to the Song script.")
    var scriptArgs: [String] = []
    
    private var interactive = true

    mutating func run() throws {
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
        
        func loadLines(from filename: String) throws -> [String] {
            
            let contents = try NSString(contentsOfFile: filename,
                                        encoding: String.Encoding.utf8.rawValue)
            
            var lines = [String]()
            contents.enumerateLines({ (line, stop) -> () in
                lines.append("\(line)")
            })
            if let line = lines.first, line.hasPrefix("#!") {
                lines.removeFirst()
            }
            return lines
        }
        
        if let filename = filename {
            interactive = false
            lines = try loadLines(from: filename)
        }
        
        func getLine() throws -> String? {
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
                    return nil
                }
            }
        }
        
        let parser = SongParser()
        
        func log(_ str: Any? = nil) {
            if interactive, let str = str {
                print(str)
            }
        }
        
        var allArgs = scriptArgs
        if let filename {
            allArgs.insert(filename, at: 0)
        }
        let songArgs = allArgs.map { Expression.string($0) }
        var context: Context = interactive ? .interactive : .script.extend(name: "args", value: .list(songArgs))
        
        let interpreter = Interpreter(initialContext: context, interactive: interactive)
        context = interpreter.context
        
        func dumpContext() {
            print(context as AnyObject)
        }
        
        log("Song v0.9.1 🎵")
        
        while (true) {
            
            guard let thisLine = try getLine() else { break }
            
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
            
            let parseResult = parser.parseResult(line)
            if verbose {
                print("  \(line), \(multilines), \(parseResult)")
            }
            switch parseResult {
            case let .success(ast):
                multilines.removeAll()
                do {
                    let expression = try ast.evaluate(context: context)
                    if case .closure(let name, _, _) = expression {
                        if let name = name {
                            context = context.extend(name: name, value: expression)
                        }
                    }
                    if case .assign(let variable, let value) = expression {
                        if case .name(let name) = variable {
                            context = context.extend(name: name, value: value)
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
                        preconditionFailure()
                    }
                } catch {
                    print("Fatal error: \(error)")
                    preconditionFailure()
                }
            case let .failure(error):
                let message = error.description.trimmingCharacters(in: .whitespacesAndNewlines)
                if interactive {
                    print("💥  syntax error: \(message)")
                } else {
                    print("💥  syntax error on line \(lineNumber): \(message)")
                }
                if !interactive {
                    preconditionFailure()
                }
                multilines.removeAll()
            case .incomplete:
                break
            }
        }
        
        if !multilines.isEmpty {
            print("💥  incomplete expression; do you have a typo?\n\n\(multilines.joined(separator: "\n"))")
        } else {
            log("👏")
        }
    }
}

Song.main()
