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

        case .bool, .number, .char, .closure, .ignore:
            return expression

        case let .list(exprs):
            let evaluated = try exprs.map { try $0.evaluate(context: context) }
            return .list(evaluated)

        case let .listCons(heads, tail):
            let evaluatedHeads = try heads.map { try $0.evaluate(context: context) }
            let evaluatedTail = try tail.evaluate(context: context)
            guard case var .list(items) = evaluatedTail else { throw EvaluationError.notAList(evaluatedTail) }
            items.insert(contentsOf: evaluatedHeads, at: 0)
            return .list(items)

        case let .variable(variable):
            return try evaluateVariable(variable: variable, context)

        case let .subfunction(subfunction):
            return try evaluate(expression: expression, subfunction: subfunction, context: context)

        case let .assign(variable, value):
            return .assign(variable: variable, value: try value.evaluate(context: context))

        case let .call(name, arguments):
            return try evaluateCall(expression: expression, name: name, arguments: arguments, context: context)

        case let .callAnon(subfunction, arguments):
            return try evaluateCallAnonymous(closure: subfunction, arguments: arguments, callingContext: context)

        case let .scope(statements):
            return try evaluateScope(statements: statements, context: context)
        }
    }
    
    func evaluateCall(expression: Expression, name: String, arguments: [Expression], context: Context) throws -> Expression {

        switch name {
        case "*":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .number(left.times(right))
        case "/":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .number(left.floatDividedBy(right))
        case "Mod":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .number(try left.modulo(right))
        case "Div":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .number(try left.integerDividedBy(right))
        case "+":
            guard arguments.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
            let result: Expression
            do {
                result = try numberOp(arguments: arguments, context: context) {
                     .number($0.plus($1))
                }
            } catch EvaluationError.notANumber {
                result = try listOp(arguments: arguments, context: context) {
                    .list($0 + $1)
                }
            }
            return result
        case "-":
            var numbers = try toNumbers(arguments: arguments, context: context)
            if numbers.count == 1 {
                let right = numbers.removeFirst()
                return .number(right.negate())
            } else if numbers.count == 2 {
                let left = numbers.removeFirst()
                let right = numbers.removeFirst()
                return .number(left.minus(right))
            } else {
                throw EvaluationError.signatureMismatch(arguments)
            }
        case "<":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .bool(left.lessThan(right))
        case ">":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .bool(left.greaterThan(right))
        case "<=":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .bool(left.lessThanOrEqualTo(right))
        case ">=":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = numbers.removeFirst()
            let right = numbers.removeFirst()
            return .bool(left.greaterThanOrEqualTo(right))
        case "Eq":
            return try evaluateEq(arguments: arguments, context: context)
        case "Neq":
            let equalCall = Expression.call("Eq", arguments)
            let notCall = Expression.call("Not", [equalCall])
            return try notCall.evaluate(context: context)
        case "And":
            var bools = try toBools(arguments: arguments, context: context)
            guard bools.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = bools.removeFirst()
            let right = bools.removeFirst()
            return .bool(left && right)
        case "Or":
            var bools = try toBools(arguments: arguments, context: context)
            guard bools.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = bools.removeFirst()
            let right = bools.removeFirst()
            return .bool(left || right)
        case "Not":
            var bools = try toBools(arguments: arguments, context: context)
            guard bools.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = bools.removeFirst()
            return .bool(!left)
        case "number":
            var numbers = arguments
            guard numbers.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = numbers.removeFirst()
            do {
                let string = try left.evaluate(context: context).asString()
                let number = try Number.convert(from: string)
                return Expression.number(number)
            } catch EvaluationError.numericMismatch {
                throw EvaluationError.notANumber(left)
            }
        case "truncate":
            var numbers = try toNumbers(arguments: arguments, context: context)
            guard numbers.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
            let left = numbers.removeFirst()
            return .number(left.truncate())
        case "out":
            return try evaluateOut(arguments: arguments, context: context)
        default:
            return try evaluateUserFunction(name: name, arguments: arguments, context: context)
        }
    }

    private func evaluateEq(arguments: [Expression], context: Context) throws -> Expression {
        guard arguments.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
        let result: Expression
        do {
            result = try booleanOp(arguments: arguments, context: context) {
                .bool($0 == $1)
            }
        } catch EvaluationError.notABoolean {
            do {
                result = try numberOp(arguments: arguments, context: context) {
                    try .bool($0.equalTo($1))
                }
            } catch EvaluationError.notANumber {
                do {
                    result = try characterOp(arguments: arguments, context: context) {
                        .bool($0 == $1)
                    }
                } catch EvaluationError.notACharacter {
                    result = try listOp(arguments: arguments, context: context) { left, right in
                        guard left.count == right.count else { return .bool(false) }
                        for (l, r) in zip(left, right) {
                            let lrEq = try evaluateEq(arguments: [l, r], context: context)
                            if case .bool(false) = lrEq {
                                return .bool(false)
                            }
                        }
                        return .bool(true)
                    }
                }
            }
        }
        return result
    }

    private func extractNumber(_ expression: Expression, context: Context) throws -> Number {
        if case .number(let number) = try expression.evaluate(context: context) {
            return number
        }
        throw EvaluationError.notANumber(expression)
    }

    private func extractBool(_ expression: Expression, context: Context) throws -> Bool {
        if case .bool(let value) = try expression.evaluate(context: context) {
            return value
        }
        throw EvaluationError.notABoolean(expression)
    }

    private func extractCharacter(_ expression: Expression, context: Context) throws -> Character {
        if case .char(let value) = try expression.evaluate(context: context) {
            return value
        }
        throw EvaluationError.notACharacter
    }

    private func extractList(_ expression: Expression, context: Context) throws -> [Expression] {
        if case .list(let list) = try expression.evaluate(context: context) {
            return list
        }
        throw EvaluationError.notAList(expression)
    }

    private func numberOp(arguments: [Expression], context: Context, callback: (Number, Number) throws -> Expression) throws -> Expression {
        var numbers = arguments
        let left = try extractNumber(numbers.removeFirst(), context: context)
        let right = try extractNumber(numbers.removeFirst(), context: context)
        return try callback(left, right)
    }

    private func booleanOp(arguments: [Expression], context: Context, callback: (Bool, Bool) throws -> Expression) throws -> Expression {
        var bools = arguments
        let left = try extractBool(bools.removeFirst(), context: context)
        let right = try extractBool(bools.removeFirst(), context: context)
        return try callback(left, right)
    }

    private func characterOp(arguments: [Expression], context: Context, callback: (Character, Character) throws -> Expression) throws -> Expression {
        var chars = arguments
        let left = try extractCharacter(chars.removeFirst(), context: context)
        let right = try extractCharacter(chars.removeFirst(), context: context)
        return try callback(left, right)
    }

    private func listOp(arguments: [Expression], context: Context, callback: ([Expression], [Expression]) throws -> Expression) throws -> Expression {
        var lists = arguments
        let left = try extractList(lists.removeFirst(), context: context)
        let right = try extractList(lists.removeFirst(), context: context)
        return try callback(left, right)
    }

    private func toNumbers(arguments: [Expression], context: Context) throws -> [Number] {
        return try arguments.map { arg -> Number in
            let evaluatedArg = try arg.evaluate(context: context)
            guard case let .number(n) = evaluatedArg else {
                throw EvaluationError.notANumber(evaluatedArg)
            }
            return n
        }
    }

    private func toBools(arguments: [Expression], context: Context) throws -> [Bool] {
        return try arguments.map { arg -> Bool in
            let evaluatedArg = try arg.evaluate(context: context)
            guard case let .bool(n) = evaluatedArg else {
                throw EvaluationError.notABoolean(evaluatedArg)
            }
            return n
        }
    }

    private func evaluate(expression: Expression, subfunction: Subfunction, context: Context) throws -> Expression {

        try validatePatterns(subfunction)

        var finalContext = context
        let name = subfunction.name
        var existingClauses = [Expression]()
        var existingContext = Context()

        if let name = name, let existingClosure = context[name] {
            guard case let .closure(_, clauses, closureContext) = existingClosure else {
                throw EvaluationError.notAClosure(expression)
            }
            existingClauses = clauses
            existingContext = closureContext
            finalContext.removeValue(forKey: name)
        }
        existingClauses.append(expression)
        finalContext.merge(existingContext) { l, r in l }
        return .closure(name, existingClauses, finalContext)
    }

    private func validatePatterns(_ subfunction: Subfunction) throws {
        try subfunction.patterns.forEach { pattern in
            if case .number(Number.float) = pattern {
                throw EvaluationError.patternsCannotBeFloats(pattern)
            }
        }
    }

    func evaluateVariable(variable: String, _ context: Context) throws -> Expression {
        guard
            let value = context[variable]
            else { throw EvaluationError.symbolNotFound(variable) }
        return value
    }

    func evaluateCallAnonymous(closure: Expression, arguments: [Expression], callingContext: Context) throws -> Expression {
        let evaluatedClosure = try closure.evaluate(context: callingContext)
        switch evaluatedClosure {
        case let .closure(_, functions, closureContext):
            for function in functions {
                do {
                    return try evaluateCallFunction(function: function, closureContext: closureContext, arguments: arguments, callingContext: callingContext, closure: evaluatedClosure)
                } catch EvaluationError.signatureMismatch {}
            }
            throw EvaluationError.signatureMismatch(arguments)
        default:
            throw EvaluationError.notAFunction(closure)
        }
    }
    
    func evaluateCallFunction(function: Expression, closureContext: Context, arguments: [Expression], callingContext: Context, closure: Expression) throws -> Expression {
        switch function {
        case let .subfunction(subfunction):

            let extendedContext = try matchParameters(closureContext: closureContext, callingContext: callingContext, parameters: subfunction.patterns, arguments: arguments)
            let whenEvaluated = try subfunction.when.evaluate(context: extendedContext)
            guard case .bool = whenEvaluated else { throw EvaluationError.notABoolean(subfunction.when) }
            guard case .bool(true) = whenEvaluated else { throw EvaluationError.signatureMismatch(arguments) }
            let finalContext = callingContext.merging(extendedContext) { l, r in r }
            return try subfunction.body.evaluate(context: finalContext)
        default:
            throw EvaluationError.notAFunction(closure)
        }
    }

    private func matchParameters(closureContext: Context, callingContext: Context, parameters: [Expression], arguments: [Expression]) throws -> Context {
        guard parameters.count <= arguments.count else { throw EvaluationError.signatureMismatch(arguments) }
        guard arguments.count <= parameters.count else { throw EvaluationError.signatureMismatch(arguments) }

        var extendedContext = closureContext
        var patternEqualityContext = Context()
        for (p, a) in zip(parameters, arguments) {
            (extendedContext, patternEqualityContext) = try matchAndExtend(context: extendedContext, parameter: p, argument: a, callingContext: callingContext, patternEqualityContext: patternEqualityContext)
        }
        return extendedContext
    }

    private func matchAndExtend(context: Context, parameter: Expression, argument: Expression, callingContext: Context, patternEqualityContext: Context) throws -> (Context, Context) {
        var extendedContext = context
        var patternEqualityContext = patternEqualityContext
        let evaluatedValue = try argument.evaluate(context: callingContext)
        switch parameter {
        case .ignore:
            () // Do nothing
        case .variable(let name):
            if let existingValue = patternEqualityContext[name] {
                if case .number(let numberValue) = existingValue {
                    if case .float = numberValue {
                        throw EvaluationError.patternsCannotBeFloats(argument)
                    }
                }
                if existingValue != evaluatedValue {
                    throw EvaluationError.signatureMismatch([argument])
                }
            }
            patternEqualityContext[name] = evaluatedValue
            extendedContext = extendContext(context: extendedContext, name: name, value: evaluatedValue)
        case .listCons(var paramHeads, let paramTail):
            guard case var .list(argItems) = evaluatedValue else { throw EvaluationError.signatureMismatch([argument]) }
            guard argItems.count >= paramHeads.count else { throw EvaluationError.signatureMismatch([argument]) }
            while paramHeads.count > 0 {
                let paramHead = paramHeads.removeFirst()
                let argHead = argItems.removeFirst()
                (extendedContext, patternEqualityContext) = try matchAndExtend(context: extendedContext, parameter: paramHead, argument: argHead, callingContext: callingContext, patternEqualityContext: patternEqualityContext)
            }
            let argTail = Expression.list(argItems)
            (extendedContext, patternEqualityContext) = try matchAndExtend(context: extendedContext, parameter: paramTail, argument: argTail, callingContext: callingContext, patternEqualityContext: patternEqualityContext)
        case .list(let paramItems):
            guard case let .list(argItems) = evaluatedValue else { throw EvaluationError.signatureMismatch([argument]) }
            guard paramItems.count == argItems.count else { throw EvaluationError.signatureMismatch([argument]) }
            for (p, a) in zip(paramItems, argItems) {
                (extendedContext, patternEqualityContext) = try matchAndExtend(context: extendedContext, parameter: p, argument: a, callingContext: callingContext, patternEqualityContext: patternEqualityContext)
            }
        default:
            if parameter != evaluatedValue {    // NOTE: should this use Eq operator instead of Swift equality?
                throw EvaluationError.signatureMismatch([argument])
            }
        }
        return (extendedContext, patternEqualityContext)
    }

    private func evaluateOut(arguments: [Expression], context: Context) throws -> Expression {
        let evaluated = try arguments.map { expr -> Expression in try expr.evaluate(context: context) }
        let output = evaluated.map { $0.out() }.joined(separator: " ")
        print(output)
        return .string(output)
    }

    private func evaluateUserFunction(name: String, arguments: [Expression], context: Context) throws -> Expression {
        guard
            let expr = context[name]
            else { throw EvaluationError.symbolNotFound(name) }
        return try evaluateCallAnonymous(closure: expr, arguments: arguments, callingContext: context)
    }

    // TODO: this code needs to be merged with the REPL code in main somehow.
    func evaluateScope(statements: [Expression], context: Context) throws -> Expression {
        guard statements.count > 0 else { throw EvaluationError.emptyScope }
        var allStatements = statements
        let last = allStatements.removeLast()
        var scopeContext = context
        var shadowedFunctions = Set<String>()
        for statement in allStatements {
            if case .subfunction(let subfunction) = statement {
                if let name = subfunction.name {
                    if !shadowedFunctions.contains(name) {
                        scopeContext.removeValue(forKey: name)
                    }
                    shadowedFunctions.insert(name)
                }
            }
            let result = try statement.evaluate(context: scopeContext)
            if case .closure(let name, _, _) = result {
                if let name = name {
                    scopeContext = extendContext(context: scopeContext, name: name, value: result)
                }
            }
            if case .assign(let variable, let value) = result {
                if case .variable(let name) = variable {
                    scopeContext = extendContext(context: scopeContext, name: name, value: value)
                }
            }
        }
        return try last.evaluate(context: scopeContext)
    }
}
