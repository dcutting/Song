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
    let quote = str("\"")
    let escape = str("\\")
    let digit = (0...9).match
    let letter = "abcdefghijklmnopqrstuvwxyz".match
    let symbol = dot | pipe | comma | lBracket | rBracket | lParen | rParen
    let character = Deferred()
    character.parser = letter | digit | space | symbol | escape >>> (escape | quote | character)
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
    let name = (letter >>> (letter | digit).some.maybe)

    // Literal values.

    let stringValue = quote >>> character.recur.tag("stringValue") >>> quote >>> skip
    let floatValue = (minus.maybe >>> digit.some >>> dot >>> digit.some).tag("floatValue")
    let integerValue = (minus.maybe >>> digit.some).tag("integerValue")
    let numericValue = floatValue | integerValue
    let trueValue = str("yes").tag("trueValue")
    let falseValue = str("no").tag("falseValue")
    let booleanValue = trueValue | falseValue
    let list = (lBracket >>> (expression.tag("listItem") >>> (comma >>> expression.tag("listItem")).recur).maybe.tag("list") >>> rBracket)
    let listConstruction = (lBracket >>> expression.tag("listItem") >>> pipe >>> expression.tag("list") >>> rBracket)
    let literalValue = booleanValue | numericValue | stringValue | list | listConstruction

    // Patterns.

    let head = pattern.tag("head")
    let tail = pattern.tag("tail")
//    let headItems = (head >>> (comma >>> head).recur).tag("heads")
    let listPattern = lBracket >>> head >>> pipe >>> tail >>> rBracket
    let listParamPattern = lBracket >>> (pattern.tag("listItem") >>> (comma >>> pattern.tag("listItem")).recur).maybe.tag("list") >>> rBracket
    pattern.parser = listParamPattern | listPattern | literalValue.tag("literal") | name.tag("variable")

    // Expressions.

    let multiplicativeExpression = term.tag("left") >>> (skip >>> (times | dividedBy | modulo).tag("op") >>> skip >>> term.tag("right")).recur.tag("ops")

    let additiveExpression = multiplicativeExpression.tag("left") >>> (skip >>> (plus | minus).tag("op") >>> skip >>> multiplicativeExpression.tag("right")).recur.tag("ops")

    let relationalExpression = Deferred()
    relationalExpression.parser = additiveExpression.tag("left") >>> (skip >>> (lessThanOrEqual | greaterThanOrEqual | lessThan | greaterThan).tag("op") >>> skip >>> relationalExpression.tag("right")).recur.tag("ops")

    let equals = str("eq")
    let notEquals = str("neq")
    let equalityExpression = Deferred()
    equalityExpression.parser = relationalExpression.tag("left") >>> (space >>> (equals | notEquals).tag("op") >>> space >>> equalityExpression.tag("right")).recur.tag("ops")

    let andKeyword = str("and")
    let andExpression = Deferred()
    andExpression.parser = equalityExpression.tag("left") >>> (space >>> andKeyword.tag("op") >>> space >>> andExpression.tag("right")).recur.tag("ops")

    let orKeyword = str("or")
    let orExpression = Deferred()
    orExpression.parser = andExpression.tag("left") >>> (space >>> orKeyword.tag("op") >>> space >>> orExpression.tag("right")).recur.tag("ops")

    expression.parser = orExpression.parser

    // Function chains.

    let functionArguments = expression.tag("arg") >>> (comma >>> expression.tag("arg")).recur
    let functionCall = dot >>> name.tag("funcName") >>> (lParen >>> functionArguments.tag("args").maybe >>> rParen).maybe
    let functionChain = atom.tag("subject") >>> functionCall.some.tag("calls")

    let freeFunctionCall = name.tag("funcName") >>> (lParen >>> functionArguments.tag("args").maybe >>> rParen)

    // Functions.

    let parameter = pattern
    let functionSubject = parameter.tag("param").tag("subject")
    let functionName = name.tag("funcName")
    let parameters = parameter.tag("param") >>> (comma >>> parameter.tag("param")).recur
    let functionParameters = lParen >>> parameters.recur(0, 1).tag("params") >>> rParen
    let assign = skip >>> str("=") >>> skip
    let functionBody = expression.tag("body") >>> skip
    let ifKeyword = space >>> str("when") >>> space
    let guardClause = (ifKeyword >>> expression).maybe.tag("guard")
    let subjectFunction = functionSubject >>> dot >>> functionName >>> functionParameters.maybe >>> guardClause >>> assign >>> functionBody

    let freeFunction = functionName >>> functionParameters >>> guardClause >>> assign >>> functionBody

    let function = subjectFunction | freeFunction

    // Lambdas.

    let lambdaParameters = pipe >>> parameters.tag("params") >>> pipe
    let lambdaBody = expression.tag("lambdaBody") >>> skip
    let lambda = (lambdaParameters >>> lambdaBody).tag("lambda")

    // Let.

    let letExpr = str("let") >>> skip >>> (name.tag("variable") >>> assign >>> expression.tag("body")).tag("let")

    // Terms.

    let wrappedExpression = lParen >>> expression.tag("expression") >>> rParen
    atom.parser = wrappedExpression | freeFunctionCall | literalValue | name.tag("variable")// | listPattern | name

    //    let notKeyword = str("NOT").tag("not") >>> space
    //    let negatedTerm = notKeyword >>> term.tag("negatedTerm")
    //    term.parser = negatedTerm | functionChain | lambda | atom
    term.parser = functionChain | freeFunctionCall | lambda | letExpr | atom.parser!

    // Imports.

//    let importKeyword = str("Use") >>> space
//    let importFilename = stringValue
//    let `import` = importKeyword >>> importFilename.tag("import")

    // Classes.

//    let numberKeyword = str("Number") >>> skip
//    let booleanKeyword = str("Boolean") >>> skip
//    let stringKeyword = str("String") >>> skip
//    let listKeyword = str("List") >>> skip
//    let className = numberKeyword | booleanKeyword | stringKeyword | listKeyword
//    let classKeyword = str("Class") >>> space
//    let classDeclaration = classKeyword >>> className.tag("subjectType")

    // Root.

//    let statement = classDeclaration >>> `import` >>> function >>> expression
//    let program = skip >>> statement

    return function | expression
}
