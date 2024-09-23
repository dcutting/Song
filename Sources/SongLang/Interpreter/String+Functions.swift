extension Expression {

    func asString() throws -> String {
        let result: String
        if case .list(let characters) = self {
            result = try convertToString(characters: characters)
        } else {
            throw EvaluationError.notAList(self)
        }
        return result
    }

    func convertToString(characters: [Expression]) throws -> String {
        let chars: [Character] = try characters.map { item in
            if case .char(let c) = item {
                return c
            }
            throw EvaluationError.notACharacter
        }
        return String(chars)
    }
}
