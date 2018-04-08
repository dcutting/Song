public class Type { // TODO: this shouldn't be a class.
    public let name: String
    public var parent: Type?
    public let associated: [Type]

    public init(name: String, parent: Type?, associated: [Type]) {
        self.name = name
        self.parent = parent
        self.associated = associated
    }

    public static let Root = Type(name: "Root", parent: nil, associated: [])
    public static let Bool = Type(name: "Bool", parent: Root, associated: [])
    public static let Char = Type(name: "Char", parent: Root, associated: [])
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
        if associated.isEmpty {
            return name
        }
        let associatedNames = associated.map { $0.name }
        let joinedAssociatedNames = associatedNames.joined(separator: ", ")
        return "\(name)(\(joinedAssociatedNames))"
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
    case valid(Type)
    case error(TypeCheckerError)
}

public class TypeChecker {

    public func verify(expression: Expression, context: Context) -> TypeCheckerResult {
        switch expression {
        case .bool, .number, .char, .name:
            return .valid(expression.type(context: context))
        case let .call(name, args):
            guard let f = context[name] else { return .error(.unknownName(expression))}
            let fType = f.type(context: context)
            guard args.count == fType.associated.count - 1 else { return .error(.arityMismatch(expression)) }
            print("expression.type: \(expression.type)")
            print("f.type: \(f.type)")
            for (a, p) in zip(args, fType.associated) {
                let aType = a.type(context: context)
                let pName = p.name
                print("comparing: \(a, p)")
                guard pName == aType.name else { return .error(.typeMismatch(a, aType, p)) }
            }
            return .valid(expression.type(context: context))
        default:
            return .error(.invalid(expression))
        }
    }
}

public extension Expression {

    public func type(context: Context) -> Type {
        switch self {
        case .bool:
            return .Bool
        case .char:
            return .Char
        case let .number(value):
            switch value {
            case .int:
                return .Int
            case .float:
                return .Float
            }
        case let .name(name):
            let e = context[name]
            return e?.type(context: context) ?? .Root
        case let .function(f):
            let paramTypes = f.patterns.map { $0.type(context: context) }
            let returnType = f.body.type(context: context)
            return .Func("Func", paramTypes + [returnType])
        case let .closure(_, functions, _):
            guard let first = functions.first else { return .Root }
            return first.type(context: context)
        case let .call(_, args):
            let argTypes = args.map { $0.type(context: context) }
            return .Func("Call", argTypes)
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
