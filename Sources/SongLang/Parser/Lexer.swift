import Foundation

struct Lexer {
    private let input: String
    private var index: String.Index

    init(input: String) {
        self.input = input
        self.index = input.startIndex
    }

    mutating func tokenize() throws -> [Token] {
        var tokens = [Token]()
        while true {
            let trivia = readWhitespace()
            guard index < input.endIndex else {
                return tokens
            }
            let start = index
            let kind = try readToken()
            tokens.append(Token(
                kind: kind,
                range: start..<index,
                leadingWhitespace: trivia.hasWhitespace,
                leadingNewline: trivia.hasNewline
            ))
        }
    }

    private mutating func readWhitespace() -> (hasWhitespace: Bool, hasNewline: Bool) {
        var hasWhitespace = false
        var hasNewline = false
        while let character = current, character.isSongWhitespace {
            hasWhitespace = true
            if character.isSongNewline {
                hasNewline = true
            }
            advance()
        }
        return (hasWhitespace, hasNewline)
    }

    private mutating func readToken() throws -> TokenKind {
        guard let character = current else {
            throw SongParseError.unexpectedEnd(expected: "token")
        }

        switch character {
        case ".":
            advance()
            return .dot
        case "|":
            advance()
            return .pipe
        case ",":
            advance()
            return .comma
        case "[":
            advance()
            return .lBracket
        case "]":
            advance()
            return .rBracket
        case "(":
            advance()
            return .lParen
        case ")":
            advance()
            return .rParen
        case "*":
            advance()
            return .star
        case "/":
            advance()
            return .slash
        case "^":
            advance()
            return .caret
        case "%":
            advance()
            return .percent
        case "+":
            advance()
            return .plus
        case "-":
            advance()
            return .minus
        case "=":
            advance()
            return .equal
        case "<":
            advance()
            if current == "=" {
                advance()
                return .leq
            }
            return .lt
        case ">":
            advance()
            if current == "=" {
                advance()
                return .geq
            }
            return .gt
        case "\"":
            return try readString()
        case "'":
            return try readCharacter()
        default:
            if character.isSongDigit {
                return readNumber()
            }
            if character.isSongWordStart {
                return try readWord()
            }
            throw SongParseError.invalidToken(String(character))
        }
    }

    private mutating func readNumber() -> TokenKind {
        var value = ""
        while let character = current, character.isSongDigit {
            value.append(character)
            advance()
        }
        if current == ".", next?.isSongDigit == true {
            value.append(".")
            advance()
            while let character = current, character.isSongDigit {
                value.append(character)
                advance()
            }
            return .float(value)
        }
        return .integer(value)
    }

    private mutating func readWord() throws -> TokenKind {
        var value = ""
        while let character = current, character.isSongWordPart {
            value.append(character)
            advance()
        }

        switch value {
        case "Yes":
            return .yes
        case "No":
            return .no
        case "Do":
            return .do
        case "End":
            return .end
        case "When":
            return .when
        case "Div":
            return .div
        case "Mod":
            return .mod
        case "Eq":
            return .eq
        case "Neq":
            return .neq
        case "And":
            return .and
        case "Or":
            return .or
        case "Not":
            return .not
        default:
            guard value.first?.isSongNamePrefix == true else {
                throw SongParseError.invalidToken(value)
            }
            return .name(value)
        }
    }

    private mutating func readString() throws -> TokenKind {
        advance()
        var value = ""
        while let character = current {
            switch character {
            case "\"":
                advance()
                return .string(value)
            case "\\":
                value.append(try readEscape(quote: "\""))
            default:
                value.append(character)
                advance()
            }
        }
        throw SongParseError.unexpectedEnd(expected: "\"")
    }

    private mutating func readCharacter() throws -> TokenKind {
        advance()
        var value = ""
        while let character = current {
            switch character {
            case "'":
                advance()
                let characters = Array(value)
                guard characters.count == 1 else {
                    throw SongParseError.invalidToken("'\(value)'")
                }
                return .character(characters[0])
            case "\\":
                value.append(try readEscape(quote: "'"))
            default:
                value.append(character)
                advance()
            }
        }
        throw SongParseError.unexpectedEnd(expected: "'")
    }

    private mutating func readEscape(quote: Character) throws -> Character {
        advance()
        guard let character = current else {
            throw SongParseError.unexpectedEnd(expected: "escape sequence")
        }
        advance()
        switch character {
        case "\\":
            return "\\"
        case "n":
            return "\n"
        case "r":
            return "\r"
        case "t":
            return "\t"
        case quote:
            return quote
        default:
            throw SongParseError.invalidToken("\\\(character)")
        }
    }

    private var current: Character? {
        guard index < input.endIndex else {
            return nil
        }
        return input[index]
    }

    private var next: Character? {
        guard index < input.endIndex else {
            return nil
        }
        let nextIndex = input.index(after: index)
        guard nextIndex < input.endIndex else {
            return nil
        }
        return input[nextIndex]
    }

    private mutating func advance() {
        index = input.index(after: index)
    }
}

private extension Character {
    var isSongWhitespace: Bool {
        unicodeScalars.allSatisfy { CharacterSet.whitespacesAndNewlines.contains($0) }
    }

    var isSongNewline: Bool {
        self == "\n" || self == "\r"
    }

    var isSongDigit: Bool {
        asciiScalar.map { $0 >= 48 && $0 <= 57 } ?? false
    }

    var isSongNamePrefix: Bool {
        self == "_" || (asciiScalar.map { $0 >= 97 && $0 <= 122 } ?? false)
    }

    var isSongWordStart: Bool {
        isSongNamePrefix || (asciiScalar.map { $0 >= 65 && $0 <= 90 } ?? false)
    }

    var isSongWordPart: Bool {
        isSongNamePrefix ||
            (asciiScalar.map { $0 >= 65 && $0 <= 90 } ?? false) ||
            isSongDigit ||
            self == "?"
    }

    private var asciiScalar: UInt32? {
        guard unicodeScalars.count == 1, let value = unicodeScalars.first?.value, value < 128 else {
            return nil
        }
        return value
    }
}
