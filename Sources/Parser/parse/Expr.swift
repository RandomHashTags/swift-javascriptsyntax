import Lexer

extension JSParser {
    mutating func parseExpression(precedence minPrec: Int = 0) throws(JSParseError) -> JSExpr {
        var expr = try parseUnary()
        if case .symbol(var op) = currentToken, JSLexer.arithmeticTokens.contains(op), lexer.input[lexer.index] == "=" {
            op += "="
            nextToken()
            nextToken()
            expr = try .compoundAssignment(operator: op, variable: expr, value: parseExpression())
            guard currentToken == .symbol(";") else {
                throw .failedExpectation(expected: ";", expectationNote: "at end of compound assignment", actual: "\(currentToken)", index: index)
            }
            nextToken()
        } else {
            while case .symbol(let op) = currentToken, let opPrec = JSLexer.operatorPrecedence[op], opPrec >= minPrec {
                nextToken()
                var rhs = try parseUnary()
                while case .symbol(let nextOp) = currentToken,
                        let nextPrec = JSLexer.operatorPrecedence[nextOp],
                        nextPrec > opPrec {
                    rhs = try parseExpression(precedence: nextPrec)
                }
                expr = .binaryOp(op, expr, rhs)
            }
        }
        return expr
    }
}