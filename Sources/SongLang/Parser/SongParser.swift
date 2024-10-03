import Foundation
import Syft

public final class SongParser {
    public init() {}
    
    public var parser: ParserProtocol {

        // Whitespace.
        
        let spacesOrTabs = " \t".match
        let newline = str("\n")
        let whitespace = spacesOrTabs | newline
        let skipInline = spacesOrTabs.some.maybe
        let skip = whitespace.some.maybe
        
        // Punctuation.
        
        let numeral = (0...9).match
        let lowercaseLetter = "abcdefghijklmnopqrstuvwxyz".match
        let uppercaseLetter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".match
        let letter = lowercaseLetter | uppercaseLetter
        
        let dot = str(".")
        let pipe = str("|")
        let comma = str(",")
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
        let equal = skip >>> str("=") >>> skip
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
        let when = str("When")
        let `do` = str("Do")
        let end = str("End")

        let expression = Deferred()
        let wrappedExpression = lParen >>> expression.tag("wrapped") >>> rParen
        
        let itemDelimiter = skip >>> comma >>> skip

        // Lists.
        
        let listItem = skip >>> expression.tag("item") >>> skip
        let listItems = listItem >>> (itemDelimiter >>> listItem).recur
        let list = lBracket >>> listItems.recur(0, 1).tag("list") >>> rBracket
        
        let heads = listItems.tag("heads")
        let tail = skip >>> expression.tag("tail") >>> skip
        let listConstructor = lBracket >>> heads >>> pipe >>> tail >>> rBracket
        
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
        let delimiterOrNewline = (skipInline >>> newline) | itemDelimiter
        let scopeItems = scopeItem >>> (delimiterOrNewline >>> scopeItem).recur
        let scope = `do` >>> whitespace >>> scopeItems.tag("scopeItems") >>> whitespace >>> end
        
        // Lambdas.
        
        let lambdaParameter = (list | listConstructor | variable).tag("param")
        let lambdaParameters = lambdaParameter >>> (itemDelimiter >>> lambdaParameter).recur
        
        let lambda = (pipe >>> skip >>> lambdaParameters.recur(0, 1).tag("params") >>> skip >>> pipe >>> skip >>> (wrappedExpression | expression).tag("body")).tag("lambda")
        
        // Function calls.
        
        let call = Deferred()
        
        let argument = Deferred()
        let wrappedArgument = lParen >>> argument >>> rParen
        argument.parser = wrappedArgument | expression
        let arguments = argument >>> (itemDelimiter >>> argument).recur
        let wrappedArguments = lParen >>> skip >>> arguments.recur.tag("args") >>> skip >>> rParen
        
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
        
        let powerativeOp = skip >>> carat.tag("op") >>> skip
        powerative.parser = term.tag("left") >>> (powerativeOp >>> powerative.tag("right")).recur.tag("ops")
        let symbolicMultiplicativeOp = skip >>> (star | slash | percent).tag("op") >>> skip
        let wordMultiplicativeOp = whitespace >>> (mod | div).tag("op") >>> whitespace
        let multiplicativeOp = symbolicMultiplicativeOp | wordMultiplicativeOp
        multiplicative.parser = powerative.tag("left") >>> (multiplicativeOp >>> powerative.tag("right")).recur.tag("ops")
        additive.parser = multiplicative.tag("left") >>> (skip >>> (plus | minus).tag("op") >>> skip >>> multiplicative.tag("right")).recur.tag("ops")
        relational.parser = additive.tag("left") >>> (skip >>> (leq | geq | lt | gt).tag("op") >>> skip >>> additive.tag("right")).recur.tag("ops")
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
        
        let assign = skip >>> equal >>> skip
        let pattern = (literal | variable).tag("param")
        let patterns = pattern >>> (itemDelimiter >>> pattern).recur
        let functionName = name.tag("functionName")
        let functionSubject = pattern.tag("subject")
        let functionParameters = skip >>> lParen >>> skip >>> patterns.recur(0, 1).tag("params") >>> skip >>> rParen
        let `guard` = (whitespace >>> when >>> whitespace >>> expression).maybe.tag("guard")
        let functionBody = skip >>> expression.tag("body") >>> skip
        
        let subjectFunctionDeclaration = functionSubject >>> dot >>> functionName >>> functionParameters.maybe >>> `guard` >>> assign >>> functionBody
        
        let freeFunctionDeclaration = functionName >>> functionParameters >>> `guard` >>> assign >>> functionBody
        
        let functionDeclaration = subjectFunctionDeclaration | freeFunctionDeclaration

        // Variable declaration.
        
        let variableDeclarationName = variable.tag("variableDeclarationName")
        let variableDeclarationBody = expression.tag("variableDeclarationBody")
        let variableDeclaration = variableDeclarationName >>> assign >>> variableDeclarationBody
        
        // Declaration.
        
        let declaration = functionDeclaration | variableDeclaration
        
        // Statement.
        
        statement.parser = declaration | expression
        
        // Root.
        
        let root = skip >>> statement >>> skip
        return root
    }
}
