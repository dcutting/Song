public enum SongExpression: Equatable, Printable {
    case SongString(String)
    
    public var description: String {
        switch self {
        case let .SongString(value):
            return "'\(value)'"
        }
    }
    
    public func evaluate() -> SongExpression {
        return self
    }
}

public func ==(lhs: SongExpression, rhs: SongExpression) -> Bool {
    switch (lhs, rhs) {
    case let (.SongString(lhsValue), .SongString(rhsValue)):
        return lhsValue == rhsValue
    }
}
