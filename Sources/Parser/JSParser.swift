import Lexer

public struct JSParser : Sendable {
    public static func parse(_ string: String) throws(JSParseError) {
        var parser = JSParser(input: string)
        while parser.currentToken != .eof {
            if let statement = try parser.parseStatement() {
                print("statement=\(statement)")
            } else {
                print("\(parser.currentToken)")
                parser.nextToken()
            }
        }
    }

    var lexer:JSLexer
    var currentToken:JSToken
    
    public init(input: String) {
        self.lexer = JSLexer(input: input)
        self.currentToken = lexer.nextToken()
    }

    /// Assigns the `currentToken` to the next token the lexer finds. 
    mutating func nextToken() {
        currentToken = lexer.nextToken()
    }
}