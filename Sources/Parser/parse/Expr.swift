import Lexer

extension JSParser {
    mutating func parseExpression(precedence minPrec: Int = 0) -> JSExpr {
        var expr = parseUnary()
        if case .symbol(let op) = currentToken, JSLexer.compoundArithmeticTokens.contains(op) {
            let lhs = expr
            skip()
            return .compoundAssignment(operator: op, variable: lhs, value: parseExpression())
        }
        if currentToken == .symbol("=") {
            let lhs = expr
            skip()
            return .assignment(variable: lhs, value: parseExpression())
        }
        while case .symbol(let op) = currentToken, let opPrec = JSLexer.operatorPrecedence[op], opPrec >= minPrec {
            skip()
            var rhs = parseUnary()
            while case .symbol(let nextOp) = currentToken,
                    let nextPrec = JSLexer.operatorPrecedence[nextOp],
                    nextPrec > opPrec {
                rhs = parseExpression(precedence: nextPrec)
            }
            expr = .binaryOp(op, expr, rhs)
        }
        return expr
    }
}