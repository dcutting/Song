import Foundation

struct Token {
    let kind: TokenKind
    let range: Range<String.Index>
    let leadingWhitespace: Bool
    let leadingNewline: Bool
}

enum TokenKind: Equatable {
    case name(String)
    case integer(String)
    case float(String)
    case string(String)
    case character(Character)
    case yes
    case no
    case `do`
    case end
    case when
    case div
    case mod
    case eq
    case neq
    case and
    case or
    case not
    case dot
    case pipe
    case comma
    case lBracket
    case rBracket
    case lParen
    case rParen
    case star
    case slash
    case caret
    case percent
    case plus
    case minus
    case equal
    case leq
    case geq
    case lt
    case gt

    var text: String {
        switch self {
        case let .name(value):
            value
        case let .integer(value), let .float(value), let .string(value):
            value
        case let .character(value):
            String(value)
        case .yes:
            "Yes"
        case .no:
            "No"
        case .do:
            "Do"
        case .end:
            "End"
        case .when:
            "When"
        case .div:
            "Div"
        case .mod:
            "Mod"
        case .eq:
            "Eq"
        case .neq:
            "Neq"
        case .and:
            "And"
        case .or:
            "Or"
        case .not:
            "Not"
        case .dot:
            "."
        case .pipe:
            "|"
        case .comma:
            ","
        case .lBracket:
            "["
        case .rBracket:
            "]"
        case .lParen:
            "("
        case .rParen:
            ")"
        case .star:
            "*"
        case .slash:
            "/"
        case .caret:
            "^"
        case .percent:
            "%"
        case .plus:
            "+"
        case .minus:
            "-"
        case .equal:
            "="
        case .leq:
            "<="
        case .geq:
            ">="
        case .lt:
            "<"
        case .gt:
            ">"
        }
    }
}
