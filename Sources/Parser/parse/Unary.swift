import Lexer

extension JSParser {
    mutating func parseUnary() -> JSExpr {
        if case .symbol(let op) = currentToken, JSLexer.unaryTokens.contains(op) {
            skip()
            return .unaryOp(op, parseUnary())
        }
        return parsePrimary()
    }
}