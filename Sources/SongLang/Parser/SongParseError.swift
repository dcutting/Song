public enum SongParseResult {
    case success(Expression)
    case incomplete(SongParseError)
    case failure(SongParseError)
}

public enum SongParseError: Error, CustomStringConvertible {
    case unexpectedEnd(expected: String)
    case unexpectedToken(String, expected: String)
    case invalidToken(String)
    case invalidNumber(String)

    public var description: String {
        switch self {
        case let .unexpectedEnd(expected):
            "Expected \(expected)"
        case let .unexpectedToken(actual, expected):
            "Expected \(expected), found \(actual)"
        case let .invalidToken(token):
            "Invalid token \(token)"
        case let .invalidNumber(number):
            "Invalid number \(number)"
        }
    }

    var isIncomplete: Bool {
        if case .unexpectedEnd = self {
            return true
        }
        return false
    }
}
