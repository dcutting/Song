typealias Number = Int

public enum EvaluationError: Error {
    case symbolNotFound(String)
    case signatureMismatch
    case notABoolean(Expression)
    case notANumber(Expression)
    case notAList(Expression)
    case notAFunction(Expression)
}

extension Expression {
    
    public func evaluate() throws -> Expression {
        return try evaluate(context: Context())
    }
    
    public func evaluate(context: Context) throws -> Expression {
        switch self {

        case .booleanValue, .integerValue, .floatValue, .stringValue, .closure:
            return self

        case let .list(exprs):
            let evaluated = try exprs.map { try $0.evaluate(context: context) }
            return .list(evaluated)

        case let .listConstructor(heads, tail):
            let evaluatedHeads = try heads.map { try $0.evaluate(context: context) }
            let evaluatedTail = try tail.evaluate(context: context)
            guard case var .list(items) = evaluatedTail else { throw EvaluationError.notAList(evaluatedTail) }
            items.insert(contentsOf: evaluatedHeads, at: 0)
            return .list(items)

        case let .variable(variable):
            return try evaluateVariable(variable: variable, context)

        case let .subfunction(subfunction):
            var finalContext = context
            if let name = subfunction.name {
                finalContext.removeValue(forKey: name)
            }
            return .closure(closure: self, context: finalContext)

        case let .constant(name, value):
            return .constant(name: name, value: try value.evaluate(context: context))

        case let .call(name: name, arguments: arguments):
            return try evaluateCall(name: name, arguments: arguments, context: context)
            
        case let .callAnonymous(subfunction, arguments):
            return try evaluateCallAnonymous(closure: subfunction, arguments: arguments, callingContext: context)
        }
    }
    
    func evaluateCall(name: String, arguments: [Expression], context: Context) throws -> Expression {

        switch name {
        case "*":
            let numbers = try toNumbers(arguments: arguments, context: context)
            let result = numbers.reduce(1) { a, n in a * n }
            return Expression.integerValue(result)
        case "/":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count > 0 else { throw EvaluationError.signatureMismatch }
            let first = numbers.removeFirst()
            let result = numbers.reduce(first) { a, n in a / n }
            return Expression.integerValue(result)
        case "%":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count > 0 else { throw EvaluationError.signatureMismatch }
            let first = numbers.removeFirst()
            let result = numbers.reduce(first) { a, n in a % n }
            return Expression.integerValue(result)
        case "+":
            let numbers = try toNumbers(arguments: arguments, context: context)
            let result = numbers.reduce(0) { a, n in a + n }
            return Expression.integerValue(result)
        case "-":
            let numbers = try toNumbers(arguments: arguments, context: context)
            let normalisedNumbers = numbers.enumerated().map { (i, n) in
                return i > 0 ? -n : n
            }
            let result = normalisedNumbers.reduce(0) { a, n in a + n }
            return Expression.integerValue(result)
        case "<":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a < b }
        case ">":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a > b }
        case "<=":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a <= b }
        case ">=":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a >= b }
        case "eq":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a == b }
        case "neq":
            return try evaluateRelational(arguments: arguments, context: context) { a, b in a != b }
        case "and":
            return try evaluateLogical(arguments: arguments, context: context) { a, b in a && b }
        case "or":
            return try evaluateLogical(arguments: arguments, context: context) { a, b in a || b }
        case "out":
            return try evaluateOut(arguments: arguments, context: context)
        default:
            return try evaluateUserFunction(name: name, arguments: arguments, context: context)
        }
    }

    private func evaluateRelational(arguments: [Expression], context: Context, callback: (Number, Number) -> Bool) throws -> Expression {
        var numbers = try toNumbers(arguments: arguments, context: context)
        guard numbers.count > 0 else { throw EvaluationError.signatureMismatch }
        let first = numbers.removeFirst()
        let (result, _) = numbers.reduce((true, first)) { a, n in
            let (v, x) = a
            return (v && callback(x, n), n)
        }
        return Expression.booleanValue(result)
    }

    private func toNumbers(arguments: [Expression], context: Context) throws -> [Number] {
        return try arguments.map { arg -> Number in
            let evaluatedArg = try arg.evaluate(context: context)
            guard case let .integerValue(n) = evaluatedArg else {
                throw EvaluationError.notANumber(evaluatedArg)
            }
            return Number(n)
        }
    }

    private func evaluateLogical(arguments: [Expression], context: Context, callback: (Bool, Bool) -> Bool) throws -> Expression {
        var bools = try toBools(arguments: arguments, context: context)
        guard bools.count > 0 else { throw EvaluationError.signatureMismatch }
        let first = bools.removeFirst()
        let (result, _) = bools.reduce((true, first)) { a, n in
            let (v, x) = a
            return (v && callback(x, n), n)
        }
        return Expression.booleanValue(result)
    }

    private func toBools(arguments: [Expression], context: Context) throws -> [Bool] {
        return try arguments.map { arg -> Bool in
            let evaluatedArg = try arg.evaluate(context: context)
            guard case let .booleanValue(n) = evaluatedArg else {
                throw EvaluationError.notABoolean(evaluatedArg)
            }
            return n
        }
    }

    func evaluateVariable(variable: String, _ context: Context) throws -> Expression {
        guard
            let values = context[variable],
            let value = values.first
            else { throw EvaluationError.symbolNotFound(variable) }
        return value
    }
    
    func evaluateCallAnonymous(closure: Expression, arguments: [Expression], callingContext: Context) throws -> Expression {
        let evaluatedClosure = try closure.evaluate(context: callingContext)
        switch evaluatedClosure {
        case let .closure(function, closureContext):
            return try evaluateCallFunction(function: function, closureContext: closureContext, arguments: arguments, callingContext: callingContext, closure: evaluatedClosure)
        default:
            throw EvaluationError.notAFunction(closure)
        }
    }
    
    func evaluateCallFunction(function: Expression, closureContext: Context, arguments: [Expression], callingContext: Context, closure: Expression) throws -> Expression {
        switch function {
        case let .subfunction(subfunction):

            let extendedContext = try matchParameters(closureContext: closureContext, callingContext: callingContext, parameters: subfunction.patterns, arguments: arguments)
            let whenEvaluated = try subfunction.when.evaluate(context: extendedContext)
            guard case .booleanValue = whenEvaluated else { throw EvaluationError.notABoolean(subfunction.when) }
            guard case .booleanValue(true) = whenEvaluated else { throw EvaluationError.signatureMismatch }
            let finalContext = callingContext.merging(extendedContext) { l, r in r }
            return try subfunction.body.evaluate(context: finalContext)
        default:
            throw EvaluationError.notAFunction(closure)
        }
    }

    private func matchParameters(closureContext: Context, callingContext: Context, parameters: [Expression], arguments: [Expression]) throws -> Context {
        guard parameters.count <= arguments.count else { throw EvaluationError.signatureMismatch }
        guard arguments.count <= parameters.count else { throw EvaluationError.signatureMismatch }

        var extendedContext = closureContext
        for (p, a) in zip(parameters, arguments) {
            extendedContext = try matchAndExtend(context: extendedContext, parameter: p, argument: a, callingContext: callingContext)
        }
        return extendedContext
    }

    private func matchAndExtend(context: Context, parameter: Expression, argument: Expression, callingContext: Context) throws -> Context {
        var extendedContext = context
        let evaluatedValue = try argument.evaluate(context: callingContext)
        switch parameter {
        case .variable(let name):
            extendedContext = extendContext(context: extendedContext, name: name, value: evaluatedValue, replacing: true)
        case .listConstructor(var paramHeads, let paramTail):
            guard case var .list(argItems) = evaluatedValue else { throw EvaluationError.signatureMismatch }
            guard argItems.count >= paramHeads.count else { throw EvaluationError.signatureMismatch }
            while paramHeads.count > 0 {
                let paramHead = paramHeads.removeFirst()
                let argHead = argItems.removeFirst()
                extendedContext = try matchAndExtend(context: extendedContext, parameter: paramHead, argument: argHead, callingContext: callingContext)
            }
            let argTail = Expression.list(argItems)
            extendedContext = try matchAndExtend(context: extendedContext, parameter: paramTail, argument: argTail, callingContext: callingContext)
        default:
            if parameter != evaluatedValue {
                throw EvaluationError.signatureMismatch
            }
        }
        return extendedContext
    }

    private func evaluateOut(arguments: [Expression], context: Context) throws -> Expression {
        let evaluated = try arguments.map { expr -> Expression in try expr.evaluate(context: context) }
        let output = evaluated.map { $0.out() }.joined(separator: " ")
        print(output)
        return .booleanValue(true)
    }

    private func evaluateUserFunction(name: String, arguments: [Expression], context: Context) throws -> Expression {
        guard
            let exprs = context[name]
            else { throw EvaluationError.symbolNotFound(name) }
        for expr in exprs {
            do {
                return try evaluateCallAnonymous(closure: expr, arguments: arguments, callingContext: context)
            } catch EvaluationError.signatureMismatch {}
        }
        throw EvaluationError.signatureMismatch
    }
}
