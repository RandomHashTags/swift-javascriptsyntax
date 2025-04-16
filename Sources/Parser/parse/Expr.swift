import Lexer

extension JSParser {
    mutating func parseExpression(precedence minPrec: Int = 0) throws(JSParseError) -> JSExpr {
        var expr = try parseUnary()
        if case .symbol(let op) = currentToken, JSLexer.compoundArithmeticTokens.contains(op) {
            let lhs = expr
            nextToken()
            return try .compoundAssignment(operator: op, variable: lhs, value: parseExpression())
        }
        if currentToken == .symbol("=") {
            let lhs = expr
            nextToken()
            return try .assignment(variable: lhs, value: parseExpression())
        }
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
        return expr
    }
}