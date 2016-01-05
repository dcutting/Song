public indirect enum Expression: Equatable, CustomStringConvertible {

    
    case Error(String)
    
    case UnitValue

    case BooleanValue(Bool)
    
    case IntegerValue(Int)
    
    case StringValue(String)
    
    case IsUnit(Expression)
    
    case Plus(Expression, Expression)
    
    case Pair(Expression, Expression)
    
    case First(Expression)
    
    case Second(Expression)
    
    case Closure(function: Expression, context: Context)
    
    case Let(name: String, binding: Expression, body: Expression)
    
    case Variable(String)
    
    case Function(name: String?, parameters: [String], body: Expression)
    
    case Call(closure: Expression, arguments: [Expression])
    
    case Conditional(condition: Expression, then: Expression, otherwise: Expression)
    
    
    public var description: String {
        switch self {
            
        case let .Error(value):
            return "<\(value)>"

        case .UnitValue:
            return "#"

        case let .BooleanValue(value):
            return value ? "yes" : "no"
            
        case let .IntegerValue(value):
            return "\(value)"
            
        case let .StringValue(value):
            return "'\(value)'"
            
        case let .IsUnit(value):
            return "isUnitValue(\(value))"
            
        case let .Plus(left, right):
            return "\(left) + \(right)"
            
        case let .Pair(first, second):
            return "(\(first), \(second))"
            
        case let .First(value):
            return "first(\(value))"
            
        case let .Second(value):
            return "second(\(value))"
        
        case let .Closure(function, context):
            let contextList = contextDescription(context)
            return "[(\(contextList)) \(function)]"

        case let .Let(name, binding, body):
            return "let (\(name) = \(binding)) { \(body) }"
        
        case let .Variable(variable):
            return "\(variable)"
            
        case let .Function(name, parameters, body):
            return descriptionFunction(name, parameters, body)
            
        case let .Call(closure, arguments):
            return descriptionCall(closure, arguments: arguments)
            
        case let .Conditional(condition, then, otherwise):
            return "if \(condition) then \(then) else \(otherwise) end"
        }
    }
    
    func descriptionFunction(name: String?, _ parameters: [String], _ body: Expression) -> String {
        let parametersList = parameters.joinWithSeparator(", ")
        if let funcName = name {
            return "def \(funcName)(\(parametersList)) { \(body) }"
        } else {
            return "λ(\(parametersList)) { \(body) }"
        }
    }
    
    func descriptionCall(closure: Expression, arguments: [Expression]) -> String {
        var argumentStrings = Array<String>()
        for arg in arguments {
            argumentStrings.append("\(arg)")
        }
        let argumentsList = argumentStrings.joinWithSeparator(", ")
        return "\(closure)(\(argumentsList))"
    }
    
    public func evaluate() -> Expression {
        return evaluate(Context())
    }
    
    public func evaluate(context: Context) -> Expression {
        switch self {

        case let .IsUnit(value):
            return evaluateIsUnit(value, context: context)
            
        case let .Plus(left, right):
            return evaluatePlus(left, right, context: context)
            
        case let .Let(name, binding, body):
            return evaluateLet(name, binding, body, context)
            
        case let .Variable(variable):
            return evaluateVariable(variable, context)

        case .Function:
            return Closure(function: self, context: context)
            
        case let .Call(closure, arguments):
            return evaluateCallClosure(closure, arguments: arguments, callingContext: context)

        case let .Conditional(condition, then, otherwise):
            return evaluateConditional(condition, then: then, otherwise: otherwise, context: context)
            
        case let .First(pair):
            return evaluateFirst(pair, context: context)
            
        case let .Second(pair):
            return evaluateSecond(pair, context: context)
            
        default:
            return self
        }
    }

    func evaluateIsUnit(value: Expression, context: Context) -> Expression {
        switch value.evaluate(context) {
        case .UnitValue:
            return BooleanValue(true)
        default:
            return BooleanValue(false)
        }
    }
    
    func evaluatePlus(left: Expression, _ right: Expression, context: Context) -> Expression {
        let evaluatedLeft = left.evaluate(context)
        let evaluatedRight = right.evaluate(context)
        switch (evaluatedLeft, evaluatedRight) {
        case let (.IntegerValue(leftValue), .IntegerValue(rightValue)):
            return Expression.IntegerValue(leftValue + rightValue)
        default:
            return Error("cannot add \(evaluatedLeft) to \(evaluatedRight)")
        }
    }
    
    func evaluateLet(name: String, _ binding: Expression, _ body: Expression, _ context: Context) -> Expression {
        let letContext = extendContext(context, name: name, value: binding.evaluate(context))
        return body.evaluate(letContext)
    }
    
    func evaluateVariable(variable: String, _ context: Context) -> Expression {
        if let value = context[variable] {
            return value
        }
        return Error("cannot evaluate \(variable)")
    }
    
    func evaluateCallClosure(closure: Expression, arguments: [Expression], callingContext: Context) -> Expression {
        let evaluatedClosure = closure.evaluate(callingContext)
        switch evaluatedClosure {
        case let .Closure(function, closureContext):
            return evaluateCallFunction(function, closureContext: closureContext, arguments: arguments, callingContext: callingContext, closure: evaluatedClosure)
        default:
            return Error("\(closure) is not a closure")
        }
    }
    
    func evaluateCallFunction(function: Expression, closureContext: Context, arguments: [Expression], callingContext: Context, closure: Expression) -> Expression {
        switch function {
        case let .Function(name, parameters, body):
            if arguments.count < parameters.count {
                return Expression.Error("not enough arguments")
            }
            if arguments.count > parameters.count {
                return Expression.Error("too many arguments")
            }
            let extendedContext = extendContext(closureContext, parameters: parameters, arguments: arguments, callingContext: callingContext)
            var finalContext = extendedContext
            if let funcName = name {
                finalContext = extendContext(finalContext, name: funcName, value: closure)
            }
            return body.evaluate(finalContext)
        default:
            return Error("closure does not wrap function")
        }
    }
    
    func evaluateConditional(condition: Expression, then: Expression, otherwise: Expression, context: Context) -> Expression {
        switch condition.evaluate(context) {
        case .BooleanValue(true):
            return then.evaluate(context)
        case .BooleanValue(false):
            return otherwise.evaluate(context)
        default:
            return Error("boolean expression expected")
        }
    }
    
    func evaluateFirst(pair: Expression, context: Context) -> Expression {
        let evaluatedPair = pair.evaluate(context)
        switch evaluatedPair {
        case let Pair(fst, _):
            return fst.evaluate(context)
        default:
            return Error("requires pair")
        }
    }
    
    func evaluateSecond(pair: Expression, context: Context) -> Expression {
        let evaluatedPair = pair.evaluate(context)
        switch evaluatedPair {
        case let Pair(_, snd):
            return snd.evaluate(context)
        default:
            return Error("requires pair")
        }
    }
}

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
        
    case let (.Error(lhsError), .Error(rhsError)):
        return lhsError == rhsError

    case (.UnitValue, .UnitValue):
        return true
        
    case let (.BooleanValue(lhsValue), .BooleanValue(rhsValue)):
        return lhsValue == rhsValue
        
    case let (.IntegerValue(lhsValue), .IntegerValue(rhsValue)):
        return lhsValue == rhsValue
    
    case let (.StringValue(lhsValue), .StringValue(rhsValue)):
        return lhsValue == rhsValue
    
    case let (.Pair(lhsFirst, lhsSecond),
        .Pair(rhsFirst, rhsSecond)):
        return lhsFirst == rhsFirst && lhsSecond == rhsSecond
    
    case let (.Closure(lhsFunction, lhsContext), .Closure(rhsFunction, rhsContext)):
        return lhsFunction == rhsFunction && lhsContext == rhsContext
        
    case let (.Variable(lhsVariable), .Variable(rhsVariable)):
        return lhsVariable == rhsVariable
    
    case let (.Function(lhsName, lhsParameters, lhsBody), .Function(rhsName, rhsParameters, rhsBody)):
        return lhsName == rhsName && lhsParameters == rhsParameters && lhsBody == rhsBody
    
    default:
        return false
    }
}
