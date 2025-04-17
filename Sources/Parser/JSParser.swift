import Lexer

public struct JSParser : Sendable {
    public static func parse(_ string: String) throws(JSParseError) -> JSSourceCode {
        var code:JSSourceCode = .init()
        var parser = JSParser(input: string)
        while parser.currentToken != .eof {
            try code.syntax.append(parser.parseSyntax())
        }
        return code
    }

    var lexer:JSLexer
    var currentToken:JSToken

    var index : Int { lexer.input.distance(from: lexer.input.startIndex, to: lexer.index) }
    
    public init(input: String) {
        self.lexer = JSLexer(input: input)
        self.currentToken = lexer.nextToken()
    }

    /// Assigns the `currentToken` to the next token the lexer finds. 
    mutating func nextToken() {
        currentToken = lexer.nextToken()
    }
}