import Lexer

extension JSParser {
    mutating func parseUnary() throws(JSParseError) -> JSExpr {
        if case .symbol(let op) = currentToken, JSLexer.unaryTokens.contains(op) {
            skip()
            return try .unaryOp(op, parseUnary())
        }
        return try parsePrimary()
    }
}