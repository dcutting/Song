var _stdIn: StdIn = DefaultStdIn()
var _stdOut: StdOut = DefaultStdOut()
var _stdErr: StdOut = DefaultStdErr()

public let rootContext: Context = [
    "Eq": .builtIn(evaluateEq),
    "Neq": .builtIn(evaluateNeq),
    "Not": .builtIn(evaluateNot),
    "And": .builtIn(evaluateAnd),
    "Or": .builtIn(evaluateOr),
    "number": .builtIn(evaluateNumberConstructor),
    "string": .builtIn(evaluateStringConstructor),
    "truncate": .builtIn(evaluateTruncateConstructor),
    "+": .builtIn(evaluatePlus),
    "-": .builtIn(evaluateMinus),
    "*": .builtIn(evaluateTimes),
    "/": .builtIn(evaluateDividedBy),
    "Mod": .builtIn(evaluateMod),
    "Div": .builtIn(evaluateDiv),
    "<": .builtIn(evaluateLessThan),
    ">": .builtIn(evaluateGreaterThan),
    "<=": .builtIn(evaluateLessThanOrEqual),
    ">=": .builtIn(evaluateGreaterThanOrEqual),
    "in": .builtIn(evaluateIn),
    "out": .builtIn(evaluateOut),
    "err": .builtIn(evaluateErr),
]

extension Expression {

    public func evaluate() throws -> Expression {
        return try evaluate(context: rootContext)
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

        case .bool, .number, .char, .ignore, .closure, .tailEval, .builtIn:
            return expression

        case let .list(exprs):
            let evaluated = try exprs.map { try $0.evaluate(context: context) }
            return .list(evaluated)

        case let .cons(heads, tail):
            let evaluatedHeads = try heads.map { try $0.evaluate(context: context) }
            let evaluatedTail = try tail.evaluate(context: context)
            guard case var .list(items) = evaluatedTail else { throw EvaluationError.notAList(evaluatedTail) }
            items.insert(contentsOf: evaluatedHeads, at: 0)
            return .list(items)

        case let .name(variable):
            return try evaluateVariable(variable: variable, context)

        case let .function(function):
            return try evaluate(expression: expression, function: function, context: context)

        case let .assign(variable, value):
            return .assign(variable: variable, value: try value.evaluate(context: context))

        case let .scope(statements):
            return try evaluateScope(statements: statements, context: context)

        case let .call(name, arguments):
            let evalArgs = try evaluate(arguments: arguments, context: context)
            var intermediate = try evaluateCall(name: name, arguments: evalArgs, context: context)
            // Trampoline tail calls.
            while case let .tailEval(tailExpr, tailArgs) = intermediate {
                intermediate = try evaluateCallAnonymous(closure: tailExpr, arguments: tailArgs, callingContext: context)
            }
            return intermediate

        case let .eval(function, arguments):
            let evalArgs = try evaluate(arguments: arguments, context: context)
            return try evaluateCallAnonymous(closure: function, arguments: evalArgs, callingContext: context)
        }
    }

    private func evaluate(arguments: [Expression], context: Context) throws -> [Expression] {
        return try arguments.map { try $0.evaluate(context: context) }
    }

    private func evaluate(expression: Expression, function: Function, context: Context) throws -> Expression {

        try validatePatterns(function)

        var finalContext = context
        let name = function.name
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

    private func validatePatterns(_ function: Function) throws {
        try function.patterns.forEach { pattern in
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
        case let .builtIn(builtIn):
            return try builtIn(arguments, callingContext)
        default:
            throw EvaluationError.notAFunction(closure)
        }
    }

    func evaluateCallFunction(function: Expression, closureContext: Context, arguments: [Expression], callingContext: Context, closure: Expression) throws -> Expression {
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
                let evalArgs = try evaluate(arguments: arguments, context: finalContext)
                let expr = try evaluateVariable(variable: name, finalContext)
                return .tailEval(expr, evalArgs)
            } else if case let .scope(statements) = body {
                let (last, scopeContext) = try semiEvaluateScope(statements: statements, context: finalContext)
                let result: Expression
                if case let .call(name, arguments) = last {
                    let evalArgs = try evaluate(arguments: arguments, context: finalContext)
                    let expr = try evaluateVariable(variable: name, finalContext)
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
        guard parameters.count <= arguments.count else { throw EvaluationError.signatureMismatch(arguments) }
        guard arguments.count <= parameters.count else { throw EvaluationError.signatureMismatch(arguments) }

        var extendedContext = closureContext
        var patternEqualityContext = Context()
        for (p, a) in zip(parameters, arguments) {
            (extendedContext, patternEqualityContext) = try matchAndExtend(context: extendedContext, parameter: p, value: a, patternEqualityContext: patternEqualityContext)
        }
        return extendedContext
    }

    private func matchAndExtend(context: Context, parameter: Expression, value: Expression, patternEqualityContext: Context) throws -> (Context, Context) {
        var extendedContext = context
        var patternEqualityContext = patternEqualityContext
        switch parameter {
        case .ignore:
            () // Do nothing
        case .name(let name):
            if let existingValue = patternEqualityContext[name] {
                if case .number(let numberValue) = existingValue {
                    if case .float = numberValue {
                        throw EvaluationError.patternsCannotBeFloats(value)
                    }
                }
                if existingValue != value {
                    throw EvaluationError.signatureMismatch([value])
                }
            }
            patternEqualityContext[name] = value
            extendedContext = extendContext(context: extendedContext, name: name, value: value)
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

    private func evaluateCall(name: String, arguments: [Expression], context: Context) throws -> Expression {
        guard
            let expr = context[name]
            else { throw EvaluationError.symbolNotFound(name) }
        return try evaluateCallAnonymous(closure: expr, arguments: arguments, callingContext: context)
    }

    // TODO: this code needs to be merged with the REPL code in main somehow.
    func evaluateScope(statements: [Expression], context: Context) throws -> Expression {
        let (last, scopeContext) = try semiEvaluateScope(statements: statements, context: context)
        return try last.evaluate(context: scopeContext)
    }

    func semiEvaluateScope(statements: [Expression], context: Context) throws -> (Expression, Context) {

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
                let evalArgs = try evaluate(arguments: arguments, context: scopeContext)
                let expr = try evaluateVariable(variable: name, scopeContext)
                result = try evaluateCallAnonymous(closure: expr, arguments: evalArgs, callingContext: context)
            } else {
                result = try statement.evaluate(context: scopeContext)
            }

            if case .closure(let name, _, _) = result {
                if let name = name {
                    scopeContext = extendContext(context: scopeContext, name: name, value: result)
                }
            }
            if case .assign(let variable, let value) = result {
                if case .name(let name) = variable {
                    scopeContext = extendContext(context: scopeContext, name: name, value: value)
                }
            }
        }

        return (last, scopeContext)
    }
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

func evaluateEq(arguments: [Expression], context: Context) throws -> Expression {
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
                    guard left.count == right.count else { return .no }
                    for (l, r) in zip(left, right) {
                        let lrEq = try evaluateEq(arguments: [l, r], context: context)
                        if case .no = lrEq {
                            return .no
                        }
                    }
                    return .yes
                }
                // TODO: need propr equality check for listCons too.
            }
        }
    }
    return result
}

func evaluateNeq(arguments: [Expression], context: Context) throws -> Expression {
    let equalCall = Expression.call("Eq", arguments)
    let notCall = Expression.call("Not", [equalCall])
    return try notCall.evaluate(context: context)
}

func evaluateNot(arguments: [Expression], context: Context) throws -> Expression {
    var bools = try toBools(arguments: arguments, context: context)
    guard bools.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = bools.removeFirst()
    return .bool(!left)
}

func evaluatePlus(arguments: [Expression], context: Context) throws -> Expression {
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
}

func evaluateTimes(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(left.times(right))
}

func evaluateDividedBy(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(left.floatDividedBy(right))
}

func evaluateMod(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(try left.modulo(right))
}

func evaluateDiv(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .number(try left.integerDividedBy(right))
}

func evaluateMinus(arguments: [Expression], context: Context) throws -> Expression {
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
}

func evaluateLessThan(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .bool(left.lessThan(right))
}

func evaluateGreaterThan(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .bool(left.greaterThan(right))
}

func evaluateLessThanOrEqual(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .bool(left.lessThanOrEqualTo(right))
}

func evaluateGreaterThanOrEqual(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    let right = numbers.removeFirst()
    return .bool(left.greaterThanOrEqualTo(right))
}

func evaluateAnd(arguments: [Expression], context: Context) throws -> Expression {
    var bools = try toBools(arguments: arguments, context: context)
    guard bools.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = bools.removeFirst()
    let right = bools.removeFirst()
    return .bool(left && right)
}

func evaluateOr(arguments: [Expression], context: Context) throws -> Expression {
    var bools = try toBools(arguments: arguments, context: context)
    guard bools.count == 2 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = bools.removeFirst()
    let right = bools.removeFirst()
    return .bool(left || right)
}

func evaluateNumberConstructor(arguments: [Expression], context: Context) throws -> Expression {
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
}

private func evaluateStringConstructor(arguments: [Expression], context: Context) throws -> Expression {
    let output = try prepareOutput(for: arguments, context: context)
    return .string(output)
}

private func evaluateIn(arguments: [Expression], context: Context) throws -> Expression {
    // TODO: anywhere I map arguments to an evaluation, they may be calling `in`...
    let evaluated = try arguments.map { expr -> Expression in try expr.evaluate(context: context) }
    let output = evaluated.map { $0.out() }.joined(separator: " ")
    _stdOut.put(output)
    let line = _stdIn.get() ?? ""
    return .string(line)
}

private func evaluateOut(arguments: [Expression], context: Context) throws -> Expression {
    let output = try prepareOutput(for: arguments, context: context)
    _stdOut.put(output + "\n")
    return .string(output)
}

private func evaluateErr(arguments: [Expression], context: Context) throws -> Expression {
    let output = try prepareOutput(for: arguments, context: context)
    _stdErr.put(output + "\n")
    return .string(output)
}

private func prepareOutput(for arguments: [Expression], context: Context) throws -> String {
    let evaluated = try arguments.map { expr -> Expression in try expr.evaluate(context: context) }
    return evaluated.map { $0.out() }.joined(separator: " ")
}

private func evaluateTruncateConstructor(arguments: [Expression], context: Context) throws -> Expression {
    var numbers = try toNumbers(arguments: arguments, context: context)
    guard numbers.count == 1 else { throw EvaluationError.signatureMismatch(arguments) }
    let left = numbers.removeFirst()
    return .number(left.truncate())
}
