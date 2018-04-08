public class Type {
    public let name: String
    public let parent: Type?
    public let associated: [Type]

    public init(name: String, parent: Type?, associated: [Type]) {
        self.name = name
        self.parent = parent
        self.associated = associated
    }

    public static let Root = Type(name: "Root", parent: nil, associated: [])
    public static let Bool = Type(name: "Bool", parent: Root, associated: [])
    public static let Number = Type(name: "Number", parent: Root, associated: [])
    public static let Int = Type(name: "Int", parent: Number, associated: [])
    public static let Float = Type(name: "Float", parent: Number, associated: [])
    public static func ListOf(_ type: Type) -> Type {
        return Type(name: "List", parent: Root, associated: [type])
    }
    public static func Func(_ name: String, _ types: [Type]) -> Type {
        return Type(name: name, parent: Root, associated: types)
    }
}

extension Type: CustomStringConvertible {
    public var description: String {
        return name
    }
}

public enum TypeCheckerError {
    case invalid(Expression)
    case unknownName(Expression)
    case notAClosure(Expression)
    case notAFunction(Expression)
    case arityMismatch(Expression)
    case typeMismatch(Expression, Type, Type)
}

public enum TypeCheckerResult {
    case success(Type)
    case error(TypeCheckerError)
}

public class TypeChecker {

    public func verify(expression: Expression, context: Context) -> TypeCheckerResult {
        switch expression {
        case .bool, .number:
            return .success(expression.type)
        case let .call(name, args):
            guard let v = context[name] else { return .error(.unknownName(expression))}
            guard case let .closure(_, functions, _) = v else { return .error(.notAClosure(expression)) }
            for function in functions {
                guard case let .function(f) = function else { return .error(.notAFunction(expression)) }
                guard args.count == f.type.associated.count - 1 else { return .error(.arityMismatch(expression)) }
                for (a, p) in zip(args, f.type.associated) {
                    let pName = p.name
                    let aName = a.type.name
                    guard pName == aName else { return .error(.typeMismatch(a, a.type, p)) }
                }
            }
            return .success(expression.type)
        default:
            return .error(.invalid(expression))
        }
    }
}

public extension Expression {

    public var type: Type {
        switch self {
        case .bool:
            return .Bool
        case let .number(value):
            switch value {
            case .int:
                return .Int
            case .float:
                return .Float
            }
        default:
            return .Root
        }
    }
}

public extension Expression {

    public func verify(context: Context) -> TypeCheckerResult {
        let typeChecker = TypeChecker()
        return typeChecker.verify(expression: self, context: context)
    }
}
