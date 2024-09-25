extension Expression {
    func asString() throws -> String {
        guard case .list(let characters) = self else {
            throw EvaluationError.notAList(self)
        }
        return try convertToString(characters: characters)
    }

    func convertToString(characters: [Expression]) throws -> String {
        let chars: [Character] = try characters.map { item in
            guard case .char(let c) = item else {
                throw EvaluationError.notACharacter(item)
            }
            return c
        }
        return String(chars)
    }
}
