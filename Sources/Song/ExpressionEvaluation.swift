public indirect enum EvaluationError: Error {
    case symbolNotFound(String)
    case signatureMismatch
    case cannotEvaluate(Expression, EvaluationError)
    case notABoolean(Expression)
    case notANumber(Expression)
    case notAList(Expression)
    case notAFunction(Expression)
    case invalidPattern(Expression)
    case emptyScope(Expression)
}

extension Expression {
    
    public func evaluate() throws -> Expression {
        return try evaluate(context: Context())
    }
    
    public func evaluate(context: Context) throws -> Expression {
        let result: Expression
        do {
            result = try evaluate(expression: self, context: context)
        } catch let error as EvaluationError {
            throw EvaluationError.cannotEvaluate(self, error)
        }
        return result
    }

    private func evaluate(expression: Expression, context: Context) throws -> Expression {
        switch expression {

        case .booleanValue, .numberValue, .stringValue, .closure, .anyVariable:
            return expression

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
            return try evaluate(expression: expression, subfunction: subfunction, context: context)

        case let .constant(variable, value):
            return .constant(variable: variable, value: try value.evaluate(context: context))

        case let .call(name: name, arguments: arguments):
            return try evaluateCall(expression: expression, name: name, arguments: arguments, context: context)

        case let .callAnonymous(subfunction, arguments):
            return try evaluateCallAnonymous(closure: subfunction, arguments: arguments, callingContext: context)

        case let .scope(statements):
            return try evaluateScope(scope: expression, statements: statements, context: context)
        }
    }
    
    func evaluateCall(expression: Expression, name: String, arguments: [Expression], context: Context) throws -> Expression {

        switch name {
        case "*":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .numberValue(left.times(right))
        case "/":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .numberValue(left.floatDividedBy(right))
        case "mod":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .numberValue(try left.modulo(right))
        case "div":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .numberValue(try left.integerDividedBy(right))
        case "+":
            guard arguments.count == 2 else { throw EvaluationError.signatureMismatch }
            let result: Expression
            do {
                var numbers = try toNumbers(arguments: arguments, context: context)
                let left = numbers.removeFirst()
                let right = numbers.removeFirst()
                result = .numberValue(left.plus(right))
            } catch EvaluationError.notANumber {
                do {
                    var lists = arguments
                    let left = lists.removeFirst()
                    let right = lists.removeFirst()
                    if
                        case let .list(leftList) = try left.evaluate(context: context),
                        case let .list(rightList) = try right.evaluate(context: context) {
                        result = .list(leftList + rightList)
                    } else {
                        throw EvaluationError.notAList(expression)
                    }
                } catch EvaluationError.notAList {
                    var strings = arguments
                    let left = strings.removeFirst()
                    let right = strings.removeFirst()
                    if
                        case let .stringValue(leftString) = try left.evaluate(context: context),
                        case let .stringValue(rightString) = try right.evaluate(context: context) {
                        result = .stringValue(leftString + rightString)
                    } else {
                        throw EvaluationError.signatureMismatch
                    }
                }
            }
            return result
        case "-":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .numberValue(left.minus(right))
        case "<":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .booleanValue(left.lessThan(right))
        case ">":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .booleanValue(left.greaterThan(right))
        case "<=":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .booleanValue(left.lessThanOrEqualTo(right))
        case ">=":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .booleanValue(left.greaterThanOrEqualTo(right))
        case "eq":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .booleanValue(try left.equalTo(right))
        case "neq":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .booleanValue(try !left.equalTo(right))
        case "and":
            var bools = try toBools(arguments: arguments, context: context)
            guard bools.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = bools.removeFirst()
            let right = bools.removeFirst()
            return .booleanValue(left && right)
        case "or":
            var bools = try toBools(arguments: arguments, context: context)
            guard bools.count == 2 else { throw EvaluationError.signatureMismatch }
            let left = bools.removeFirst()
            let right = bools.removeFirst()
            return .booleanValue(left || right)
        case "not":
            var bools = try toBools(arguments: arguments, context: context)
            guard bools.count == 1 else { throw EvaluationError.signatureMismatch }
            let left = bools.removeFirst()
            return .booleanValue(!left)
        case "out":
            return try evaluateOut(arguments: arguments, context: context)
        default:
            return try evaluateUserFunction(name: name, arguments: arguments, context: context)
        }
    }

    private func toNumbers(arguments: [Expression], context: Context) throws -> [Number] {
        return try arguments.map { arg -> Number in
            let evaluatedArg = try arg.evaluate(context: context)
            guard case let .numberValue(n) = evaluatedArg else {
                throw EvaluationError.notANumber(evaluatedArg)
            }
            return n
        }
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

    private func evaluate(expression: Expression, subfunction: Subfunction, context: Context) throws -> Expression {
        var finalContext = context
        if let name = subfunction.name {
            finalContext.removeValue(forKey: name)
        }
        try subfunction.patterns.forEach { pattern in
            if case .numberValue(Number.float) = pattern {
                throw EvaluationError.invalidPattern(pattern)
            }
        }
        return .closure(closure: expression, context: finalContext)
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
        case .anyVariable:
            () // Do nothing
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

    func evaluateScope(scope: Expression, statements: [Expression], context: Context) throws -> Expression {
        guard statements.count > 0 else { throw EvaluationError.emptyScope(scope) }
        var allStatements = statements
        let last = allStatements.removeLast()
        var scopeContext = context
        var shadowedFunctions = Context()
        var newFunctions = Context()
        for statement in allStatements {
            let result = try statement.evaluate(context: scopeContext)
            if case .closure(let function, _) = result {
                if case .subfunction(let subfunction) = function {
                    if let name = subfunction.name {
                        if let shadowed = context[name] {
                            shadowedFunctions[name] = shadowed
                        }
                        newFunctions = extendContext(context: newFunctions, name: name, value: result, replacing: false)
                        let combined = newFunctions.merging(shadowedFunctions) { l, r in l + r }
                        scopeContext[name] = combined[name]
                    }
                }
            }
            if case .constant(let variable, let value) = result {
                if case .variable(let name) = variable {
                    scopeContext = extendContext(context: scopeContext, name: name, value: value, replacing: true)
                }
            }
        }
        return try last.evaluate(context: scopeContext)
    }
}
