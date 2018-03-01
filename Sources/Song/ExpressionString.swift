extension Expression {

    func asString() throws -> String {
        if case .list(let characters) = self {
            return try convertToString(characters: characters)
        } else {
            throw EvaluationError.notAList(self)
        }
    }

    func convertToString(characters: [Expression]) throws -> String {
        let chars: [Character] = try characters.map { item in
            if case .character(let c) = item {
                return c
            }
            throw EvaluationError.notACharacter
        }
        return String(chars)
    }
}
