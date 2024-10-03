import Foundation
import Syft

public final class SongParser {
    public init() {}
    
    public var parser: ParserProtocol {
        
        // Punctuation.
        
        let newline = str("\n")
        let space = " \t".match.some
        let whitespace = space | newline
        let skip = space.maybe
        let skipWhitespace = whitespace.some.maybe
        
        let numeral = (0...9).match
        let lowercaseLetter = "abcdefghijklmnopqrstuvwxyz".match
        let uppercaseLetter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".match
        let letter = lowercaseLetter | uppercaseLetter
        
        let dot = str(".")
        let pipe = str("|")
        let comma = skipWhitespace >>> str(",") >>> skipWhitespace
        let lBracket = str("[")
        let rBracket = str("]")
        let lParen = str("(")
        let rParen = str(")")
        let singleQuote = str("'")
        let doubleQuote = str(#"""#)
        let backslash = str(#"\"#)
        let underscore = str("_")
        let questionMark = str("?")
        let star = str("*")
        let slash = str("/")
        let carat = str("^")
        let percent = str("%")
        let plus = str("+")
        let minus = str("-")
        let equal = skipWhitespace >>> str("=") >>> skipWhitespace
        let leq = str("<=")
        let geq = str(">=")
        let lt = str("<")
        let gt = str(">")
        let div = str("Div")
        let mod = str("Mod")
        let eq = str("Eq")
        let neq = str("Neq")
        let and = str("And")
        let or = str("Or")
        let not = str("Not")
        let yes = str("Yes")
        let no = str("No")
        let when = whitespace >>> str("When") >>> whitespace
        let `do` = str("Do")
        let end = str("End")
                
        let expression = Deferred()
        let wrappedExpression = lParen >>> expression.tag("wrapped") >>> rParen
        
        // Lists.
        
        let element = skipWhitespace >>> expression.tag("item") >>> skipWhitespace
        let elements = element >>> (comma >>> element).recur
        let list = lBracket >>> elements.recur.tag("list") >>> rBracket
        
        let heads = elements.tag("heads")
        let tail = expression.tag("tail")
        let listConstructor = lBracket >>> skipWhitespace >>> heads >>> skipWhitespace >>> pipe >>> skipWhitespace >>> tail >>> skipWhitespace >>> rBracket
        
        // Literals.
        
        let trueLiteral = yes.tag("true")
        let falseLiteral = no.tag("false")
        let booleanLiteral = trueLiteral | falseLiteral
        let integerLiteral = numeral.some.tag("integer")
        let floatLiteral = (numeral.some >>> dot >>> numeral.some).tag("float")
        let numericLiteral = floatLiteral | integerLiteral

        let textAlphanumeric = Parser.char(.alphanumerics)
        let textQuoteChars = CharacterSet(charactersIn: #"'""#)
        let textBackslashChars = CharacterSet(charactersIn: #"\"#)
        let textPunctuation = Parser.char(.punctuationCharacters.subtracting(textQuoteChars).subtracting(textBackslashChars))
        let textSymbol = Parser.char(.symbols.subtracting(textQuoteChars))
        let textWhitespace = Parser.char(.whitespacesAndNewlines)
        let textCharacter = textAlphanumeric | textWhitespace | textSymbol | textPunctuation
        let textEscapedControl = backslash >>> (backslash | "nrt".match)
        let textEscapedSingleQuote = backslash >>> singleQuote
        let textEscapedDoubleQuote = backslash >>> doubleQuote
        let textLiteralChar = textEscapedControl | textCharacter
        let textLiteralCharInChar = textEscapedSingleQuote | doubleQuote | textLiteralChar
        let textLiteralCharInString = textEscapedDoubleQuote | singleQuote | textLiteralChar

        let characterLiteral = singleQuote >>> textLiteralCharInChar.tag("character") >>> singleQuote
        let stringLiteral = doubleQuote >>> textLiteralCharInString.some.maybe.tag("string") >>> doubleQuote
        
        let literal = stringLiteral | characterLiteral | list | listConstructor | numericLiteral | booleanLiteral
        
        // Names.
        
        let namePrefix = underscore | lowercaseLetter
        let nameSuffix = letter | numeral | underscore | questionMark
        let name = namePrefix >>> nameSuffix.some.maybe
        let variable = name.tag("variableName")
        
        // Scopes.
        
        let statement = Deferred()
        let scopeItem = skip >>> statement.tag("scopeStatement")
        let delimiterOrNewline = skip >>> ((comma.maybe >>> skip >>> newline) | comma)
        let scopeItems = scopeItem >>> (delimiterOrNewline >>> scopeItem).recur
        let scope = `do` >>> whitespace >>> scopeItems.tag("scopeItems") >>> whitespace >>> end
        
        // Lambdas.
        
        let lambdaParameter = (list | listConstructor | variable).tag("param")
        let lambdaParameters = lambdaParameter >>> (comma >>> lambdaParameter).recur
        
        let lambda = (pipe >>> skipWhitespace >>> lambdaParameters.recur(0, 1).tag("params") >>> skipWhitespace >>> pipe >>> skipWhitespace >>> (wrappedExpression | expression).tag("body")).tag("lambda")
        
        // Function calls.
        
        let call = Deferred()
        
        let argument = Deferred()
        let wrappedArgument = lParen >>> argument >>> rParen
        argument.parser = wrappedArgument | expression
        let argumentDelimiter = skipWhitespace >>> comma >>> skipWhitespace
        let arguments = argument >>> (argumentDelimiter >>> argument).recur
        let wrappedArguments = lParen >>> skipWhitespace >>> arguments.recur.tag("args") >>> skipWhitespace >>> rParen
        
        let callable = Deferred()
        let wrappedCallable = lParen >>> callable >>> rParen
        callable.parser = wrappedCallable | call | variable | lambda | scope
        
        let groupName = name.tag("functionName")
        let groupAnon = lParen >>> callable >>> rParen
        let groupAnonCall = groupAnon.tag("anonCall") >>> wrappedArguments.maybe
        let groupAnonCallWithArgs = groupAnon.tag("anonCall") >>> wrappedArguments
        let groupNameCall = groupName >>> wrappedArguments
        let trailCalls = (lParen >>> arguments.recur.tag("args") >>> rParen).tag("anonCall").recur
        let dotGroupCall = groupNameCall.tag("nameCall") | groupAnonCall
        let headGroupCall = groupNameCall.tag("nameCall") | groupAnonCallWithArgs
        let group = dotGroupCall | groupName.tag("nameCall") | wrappedExpression
        let dotHead = (headGroupCall >>> trailCalls).tag("trailCalls") | wrappedExpression | variable | literal
        let dotGroup = dot >>> group
        let dotCall = dotHead.tag("head") >>> dotGroup >>> trailCalls >>> (dotGroup >>> trailCalls).recur
        
        let freeCall = (dotGroupCall >>> trailCalls).tag("trailCalls")
        
        call.parser = dotCall.tag("dotCall") | freeCall
        
        // Expressions.
        
        let powerative = Deferred()
        let multiplicative = Deferred()
        let additive = Deferred()
        let relational = Deferred()
        let equality = Deferred()
        let conjunctive = Deferred()
        let disjunctive = Deferred()
        let term = Deferred()
        
        let powerativeOp = skipWhitespace >>> carat.tag("op") >>> skipWhitespace
        powerative.parser = term.tag("left") >>> (powerativeOp >>> powerative.tag("right")).recur.tag("ops")
        let symbolicMultiplicativeOp = skipWhitespace >>> (star | slash | percent).tag("op") >>> skipWhitespace
        let wordMultiplicativeOp = whitespace >>> (mod | div).tag("op") >>> whitespace
        let multiplicativeOp = symbolicMultiplicativeOp | wordMultiplicativeOp
        multiplicative.parser = powerative.tag("left") >>> (multiplicativeOp >>> powerative.tag("right")).recur.tag("ops")
        additive.parser = multiplicative.tag("left") >>> (skipWhitespace >>> (plus | minus).tag("op") >>> skipWhitespace >>> multiplicative.tag("right")).recur.tag("ops")
        relational.parser = additive.tag("left") >>> (skipWhitespace >>> (leq | geq | lt | gt).tag("op") >>> skipWhitespace >>> additive.tag("right")).recur.tag("ops")
        equality.parser = relational.tag("left") >>> (whitespace >>> (eq | neq).tag("op") >>> whitespace >>> equality.tag("right")).recur.tag("ops")
        conjunctive.parser = equality.tag("left") >>> (whitespace >>> and.tag("op") >>> whitespace >>> conjunctive.tag("right")).recur.tag("ops")
        disjunctive.parser = conjunctive.tag("left") >>> (whitespace >>> or.tag("op") >>> whitespace >>> disjunctive.tag("right")).recur.tag("ops")
        
        expression.parser = disjunctive.parser
        
        // Terms.
        
        let negateOp = (not.tag("op") >>> whitespace) | minus.tag("op")
        let negateTerm = negateOp >>> term.tag("right")
        let plusTerm = plus >>> term
        term.parser = negateTerm | plusTerm | scope | call | lambda | variable | literal | wrappedExpression
        
        // Function declarations.
        
        let pattern = (literal | variable).tag("param")
        let patterns = pattern >>> (comma >>> pattern).recur
        let functionName = name.tag("functionName")
        let functionSubject = pattern.tag("subject")
        let functionParameters = skipWhitespace >>> lParen >>> skipWhitespace >>> patterns.recur(0, 1).tag("params") >>> skipWhitespace >>> rParen
        let `guard` = (when >>> expression).maybe.tag("guard")
        let functionBody = skip >>> expression.tag("body") >>> skip
        
        let subjectFunctionDeclaration = functionSubject >>> dot >>> functionName >>> functionParameters.maybe >>> `guard` >>> equal >>> functionBody
        
        let freeFunctionDeclaration = functionName >>> functionParameters >>> `guard` >>> equal >>> functionBody
        
        let functionDeclaration = subjectFunctionDeclaration | freeFunctionDeclaration

        // Variable declaration.
        
        let variableDeclarationName = variable.tag("variableDeclarationName")
        let variableDeclarationBody = expression.tag("variableDeclarationBody")
        let variableDeclaration = variableDeclarationName >>> equal >>> variableDeclarationBody
        
        // Declaration.
        
        let declaration = functionDeclaration | variableDeclaration
        
        // Statement.
        
        statement.parser = declaration | expression
        
        // Root.
        
        let root = skipWhitespace >>> statement >>> skipWhitespace
        return root
    }
}
