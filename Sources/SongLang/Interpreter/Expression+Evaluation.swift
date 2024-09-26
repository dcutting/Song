extension Expression {
    public func evaluate(context: Context) throws -> Expression {
        do {
            return try evaluate(expression: self, context: context)
        } catch let error as EvaluationError {
            throw EvaluationError.cannotEvaluate(self, error)
        }
    }

    private func evaluate(expression: Expression, context: Context) throws -> Expression {
        switch expression {

        case .bool, .number, .char, .unnamed, .closure, .tailEval, .builtIn:
            return expression

        case let .list(items):
            return .list(try items.evaluate(context: context))

        case let .cons(heads, tail):
            let evaluatedTail = try tail.evaluate(context: context)
            guard case let .list(tailItems) = evaluatedTail else { throw EvaluationError.notAList(evaluatedTail) }
            return .list(try heads.evaluate(context: context) + tailItems)

        case let .name(variable):
            return try context.lookup(variable)

        case let .function(function):
            return try evaluate(expression: expression, function: function, context: context)

        case let .assign(variable, value):
            return .assign(variable: variable, value: try value.evaluate(context: context))

        case let .scope(statements):
            return try evaluateScope(statements: statements, context: context)

        case let .call(name, arguments):
            let evaluatedArgs = try arguments.evaluate(context: context)
            var intermediate = try evaluateCall(name: name, arguments: evaluatedArgs, context: context)
            // Trampoline tail calls.
            while case let .tailEval(tailExpr, tailArgs) = intermediate {
                intermediate = try evaluateCallAnonymous(closure: tailExpr, arguments: tailArgs, callingContext: context)
            }
            return intermediate

        case let .eval(function, arguments):
            let evalArgs = try arguments.evaluate(context: context)
            return try evaluateCallAnonymous(closure: function, arguments: evalArgs, callingContext: context)
        }
    }

    private func evaluate(expression: Expression, function: Function, context: Context) throws -> Expression {
        try validatePatterns(function: function)

        var finalContext = context
        let name = function.name
        var existingClauses = [Expression]()
        var existingContext = Context.empty

        if let name = name, let existingClosure = context[name] {
            guard case let .closure(_, clauses, closureContext) = existingClosure else {
                throw EvaluationError.notAClosure(expression)
            }
            existingClauses = clauses
            existingContext = closureContext
            finalContext.removeValue(forKey: name)
        }
        existingClauses.append(expression)
        finalContext.merge(existingContext) { l, _ in l }
        return .closure(name, existingClauses, finalContext)
    }

    private func validatePatterns(function: Function) throws {
        try function.patterns.forEach { pattern in
            if case .number(.float) = pattern {
                throw EvaluationError.patternsCannotBeFloats(pattern)
            }
        }
    }

    // TODO: this code needs to be merged with the REPL code in main somehow.
    private func evaluateScope(statements: [Expression], context: Context) throws -> Expression {
        let (last, scopeContext) = try semiEvaluateScope(statements: statements, context: context)
        switch last {
        case let .call(name, arguments):
            let evalArgs = try arguments.evaluate(context: scopeContext)
            let expr = try scopeContext.lookup(name)
            return try evaluateCallAnonymous(closure: expr, arguments: evalArgs, callingContext: context)
        default:
            return try last.evaluate(context: scopeContext)
        }
    }

    private func evaluateCall(name: String, arguments: [Expression], context: Context) throws -> Expression {
        try evaluateCallAnonymous(closure: try context.lookup(name), arguments: arguments, callingContext: context)
    }

    private func evaluateCallAnonymous(closure: Expression, arguments: [Expression], callingContext: Context) throws -> Expression {
        let evaluatedClosure = try closure.evaluate(context: callingContext)
        switch evaluatedClosure {
        case let .closure(_, functions, closureContext):
            for function in functions {
                do {
                    return try evaluateCallFunction(function: function, closureContext: closureContext, arguments: arguments, callingContext: callingContext, closure: evaluatedClosure)
                } catch EvaluationError.signatureMismatch {}
            }
            throw EvaluationError.signatureMismatch(arguments)
        case let .builtIn(builtIn):
            return try builtIn.function()(arguments, callingContext)
        default:
            throw EvaluationError.notAFunction(closure)
        }
    }

    private func evaluateCallFunction(function: Expression, closureContext: Context, arguments: [Expression], callingContext: Context, closure: Expression) throws -> Expression {
        switch function {
        case let .function(function):
            let extendedContext = try matchParameters(closureContext: closureContext, parameters: function.patterns, arguments: arguments)
            let finalContext = callingContext.merging(extendedContext) { l, r in r }
            let whenEvaluated = try function.when.evaluate(context: finalContext)
            guard case .bool = whenEvaluated else { throw EvaluationError.notABoolean(function.when) }
            guard case .yes = whenEvaluated else { throw EvaluationError.signatureMismatch(arguments) }
            let body = function.body

            // Detect tail calls if present.
            if case let .call(name, arguments) = body {
                let evalArgs = try arguments.evaluate(context: finalContext)
                let expr = try finalContext.lookup(name)
                return .tailEval(expr, evalArgs)
            } else if case let .scope(statements) = body {
                let (last, scopeContext) = try semiEvaluateScope(statements: statements, context: finalContext)
                let result: Expression
                if case let .call(name, arguments) = last {
                    let evalArgs = try arguments.evaluate(context: finalContext)
                    let expr = try finalContext.lookup(name)
                    result = .tailEval(expr, evalArgs)
                } else {
                    result = try last.evaluate(context: scopeContext)
                }
                return result
            } else {
                return try body.evaluate(context: finalContext)
            }
        default:
            throw EvaluationError.notAFunction(closure)
        }
    }

    private func matchParameters(closureContext: Context, parameters: [Expression], arguments: [Expression]) throws -> Context {
        guard parameters.count == arguments.count else { throw EvaluationError.signatureMismatch(arguments) }
        var extendedContext = closureContext
        var patternEqualityContext = Context.empty
        for (p, a) in zip(parameters, arguments) {
            (extendedContext, patternEqualityContext) = try matchAndExtend(context: extendedContext, parameter: p, value: a, patternEqualityContext: patternEqualityContext)
        }
        return extendedContext
    }

    private func matchAndExtend(context: Context, parameter: Expression, value: Expression, patternEqualityContext: Context) throws -> (Context, Context) {
        var extendedContext = context
        var patternEqualityContext = patternEqualityContext
        switch parameter {
        case .unnamed:
            () // Do nothing
        case .name(let name):
            if let existingValue = patternEqualityContext[name] {
                if case .number(.float) = existingValue {
                    throw EvaluationError.patternsCannotBeFloats(value)
                }
                if existingValue != value {
                    throw EvaluationError.signatureMismatch([value])
                }
            }
            patternEqualityContext[name] = value
            extendedContext = extendedContext.extend(name: name, value: value)
        case .cons(var paramHeads, let paramTail):
            guard case var .list(argItems) = value else { throw EvaluationError.signatureMismatch([value]) }
            guard argItems.count >= paramHeads.count else { throw EvaluationError.signatureMismatch([value]) }
            while paramHeads.count > 0 {
                let paramHead = paramHeads.removeFirst()
                let argHead = argItems.removeFirst()
                (extendedContext, patternEqualityContext) = try matchAndExtend(context: extendedContext, parameter: paramHead, value: argHead, patternEqualityContext: patternEqualityContext)
            }
            let argTail = Expression.list(argItems)
            (extendedContext, patternEqualityContext) = try matchAndExtend(context: extendedContext, parameter: paramTail, value: argTail, patternEqualityContext: patternEqualityContext)
        case .list(let paramItems):
            guard case let .list(argItems) = value else { throw EvaluationError.signatureMismatch([value]) }
            guard paramItems.count == argItems.count else { throw EvaluationError.signatureMismatch([value]) }
            for (p, a) in zip(paramItems, argItems) {
                (extendedContext, patternEqualityContext) = try matchAndExtend(context: extendedContext, parameter: p, value: a, patternEqualityContext: patternEqualityContext)
            }
        default:
            if parameter != value {    // NOTE: should this use Eq operator instead of Swift equality?
                throw EvaluationError.signatureMismatch([value])
            }
        }
        return (extendedContext, patternEqualityContext)
    }

    private func semiEvaluateScope(statements: [Expression], context: Context) throws -> (Expression, Context) {
        guard statements.count > 0 else { throw EvaluationError.emptyScope }

        var allStatements = statements
        let last = allStatements.removeLast()
        var scopeContext = context
        var shadowedFunctions = Set<String>()
        for statement in allStatements {
            if case .function(let function) = statement {
                if let name = function.name {
                    if !shadowedFunctions.contains(name) {
                        scopeContext.removeValue(forKey: name)
                    }
                    shadowedFunctions.insert(name)
                }
            }

            let result: Expression
            if case let .call(name, arguments) = statement {
                let evalArgs = try arguments.evaluate(context: scopeContext)
                let expr = try scopeContext.lookup(name)
                result = try evaluateCallAnonymous(closure: expr, arguments: evalArgs, callingContext: context)
            } else {
                result = try statement.evaluate(context: scopeContext)
            }

            if case .closure(let name, _, _) = result {
                if let name = name {
                    scopeContext = scopeContext.extend(name: name, value: result)
                }
            }
            if case .assign(let variable, let value) = result {
                if case .name(let name) = variable {
                    scopeContext = scopeContext.extend(name: name, value: value)
                }
            }
        }

        return (last, scopeContext)
    }
}

extension Array<Expression> {
    func evaluate(context: Context) throws -> [Expression] {
        try map { try $0.evaluate(context: context) }
    }
}
