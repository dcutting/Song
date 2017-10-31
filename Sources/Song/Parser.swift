import Syft

public func makeParser() -> ParserProtocol {

    // Punctuation.

    let space = " \t".match.some
    let skip = space.maybe
    let dot = str(".")
    let pipe = str("|") >>> skip
    let comma = str(",") >>> skip
    let lBracket = str("[") >>> skip
    let rBracket = str("]") >>> skip
    let lParen = str("(") >>> skip
    let rParen = str(")")
    let quote = str("'")
    let digit = (0...9).match
    let letter = "abcdefghijklmnopqrstuvwxyz".match
    let times = str("*")
    let dividedBy = str("/")
    let modulo = str("%")
    let plus = str("+")
    let minus = str("-")
    let lessThanOrEqual = str("<=")
    let greaterThanOrEqual = str(">=")
    let lessThan = str("<")
    let greaterThan = str(">")

    let expression = Deferred()
    let term = Deferred()
    let pattern = Deferred()
    let atom = Deferred()

    // Atoms.

    // RESERVED_WORDS = %w( yes no not and or if use class eq neq Boolean List String Number )
    let name = (letter >>> (letter | digit).some.maybe).tag("identifier")

    // Literal values.

    let stringValue = quote >>> letter.recur.tag("stringValue") >>> quote >>> skip
    let floatValue = (minus.maybe >>> digit.some >>> dot >>> digit.some).tag("floatValue")
    let integerValue = (minus.maybe >>> digit.some).tag("integerValue")
    let numericValue = floatValue | integerValue
    let trueValue = str("YES").tag("trueValue")
    let falseValue = str("NO").tag("falseValue")
    let booleanValue = trueValue | falseValue
    let literalValue = booleanValue | numericValue | stringValue

    // Patterns.

    let listPattern = lBracket >>> (pattern.tag("headItem") >>> (comma >>> pattern.tag("headItem")).recur).tag("headItems") >>> (pipe >>> name.tag("tail")).maybe >>> rBracket
    let listParamPattern = lBracket >>> (pattern.tag("listItem") >>> (comma >>> pattern.tag("listItem")).recur).maybe.tag("list") >>> rBracket
    pattern.parser = listParamPattern | listPattern | numericValue | trueValue | falseValue | stringValue | name

    // Expressions.

    let multiplicativeExpression = term.tag("left") >>> (skip >>> (times | dividedBy | modulo).tag("op") >>> skip >>> term.tag("right")).recur.tag("ops")

    let additiveExpression = multiplicativeExpression.tag("left") >>> (skip >>> (plus | minus).tag("op") >>> skip >>> multiplicativeExpression.tag("right")).recur.tag("ops")

    let relationalExpression = Deferred()
    relationalExpression.parser = additiveExpression.tag("left") >>> (skip >>> (lessThanOrEqual | greaterThanOrEqual | lessThan | greaterThan).tag("op") >>> skip >>> relationalExpression.tag("right")).recur.tag("ops")

    let equals = str("EQ")
    let notEquals = str("NEQ")
    let equalityExpression = Deferred()
    equalityExpression.parser = relationalExpression.tag("left") >>> (space >>> (equals | notEquals).tag("op") >>> space >>> equalityExpression.tag("right")).recur.tag("ops")

    let andKeyword = str("AND")
    let andExpression = Deferred()
    andExpression.parser = equalityExpression.tag("left") >>> (space >>> andKeyword.tag("op") >>> space >>> andExpression.tag("right")).recur.tag("ops")

    let orKeyword = str("OR")
    let orExpression = Deferred()
    orExpression.parser = andExpression.tag("left") >>> (space >>> orKeyword.tag("op") >>> space >>> orExpression.tag("right")).recur.tag("ops")

    expression.parser = orExpression.parser

    // Function chains.

    let functionArguments = expression.tag("arg") >>> (comma >>> expression.tag("arg")).recur
    let functionCall = dot >>> name.tag("funcName") >>> (lParen >>> functionArguments.tag("args").maybe >>> rParen).maybe
    let functionChain = atom.tag("subject") >>> functionCall.some.tag("calls")

    // Functions.

    let parameter = pattern
    let functionSubject = parameter.tag("defunSubject")
    let functionName = name.tag("FUNC")
    let parameters = parameter.tag("param") >>> (comma >>> parameter.tag("param")).recur
    let functionParameters = lParen >>> parameters.recur(0, 1).tag("params") >>> rParen
    let assign = skip >>> str("=") >>> skip
    let functionBody = expression.tag("body") >>> skip
    let ifKeyword = space >>> str("IF") >>> space
    let guardClause = (ifKeyword >>> expression).maybe.tag("guard")
    let function = functionSubject >>> dot >>> functionName >>> functionParameters.maybe >>> guardClause >>> assign >>> functionBody

    // Lambdas.

    let lambdaParameters = pipe >>> parameters.tag("params") >>> pipe
    let lambdaBody = expression.tag("lambdaBody") >>> skip
    let lambda = (lambdaParameters >>> lambdaBody).tag("lambda")

    // Terms.

    //    let notKeyword = str("NOT").tag("not") >>> space
    //    let negatedTerm = notKeyword >>> term.tag("negatedTerm")
    //    term.parser = negatedTerm | functionChain | lambda | atom
    term.parser = numericValue

    let list = (lBracket >>> (expression.tag("listItem") >>> (comma >>> expression.tag("listItem")).recur).maybe.tag("list") >>> rBracket)
    let wrappedExpression = lParen >>> expression.tag("expression") >>> rParen
    atom.parser = wrappedExpression | list | listPattern | numericValue | name | trueValue | falseValue | stringValue

    // Imports.

    let importKeyword = str("Use") >>> space
    let importFilename = stringValue
    let `import` = importKeyword >>> importFilename.tag("import")

    // Classes.

    let numberKeyword = str("Number") >>> skip
    let booleanKeyword = str("Boolean") >>> skip
    let stringKeyword = str("String") >>> skip
    let listKeyword = str("List") >>> skip
    let className = numberKeyword | booleanKeyword | stringKeyword | listKeyword
    let classKeyword = str("Class") >>> space
    let classDeclaration = classKeyword >>> className.tag("subjectType")

    // Root.

    let statement = classDeclaration >>> `import` >>> function >>> expression
    let program = skip >>> statement

    return expression
}
