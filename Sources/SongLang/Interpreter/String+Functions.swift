extension Expression {
    var formattedString: String {
        switch self {
        case let .char(char):
            return "\(char)"
        case let .list(exprs):
            do {
                return try toString(characters: exprs)
            } catch {
                return "\(self)"
            }
        case let .closure(_, value, _):
            return "\(value)"
        default:
            return "\(self)"
        }
    }

    func toString() throws -> String {
        guard case .list(let characters) = self else {
            throw EvaluationError.notAList(self)
        }
        return try toString(characters: characters)
    }
    
    func toString(characters: [Expression]) throws -> String {
        let chars: [Character] = try characters.map { item in
            guard case .char(let c) = item else {
                throw EvaluationError.notACharacter(item)
            }
            return c
        }
        return String(chars)
    }
}
