import Lexer

extension JSParser {
    mutating func parsePrimary() throws(JSParseError) -> JSExpr {
        var expr:JSExpr
        switch currentToken {
        case .number(let value):
            nextToken()
            expr = .number(value)
        case .string(_, let value):
            nextToken()
            return .string(value)
        case .keyword(let w) where w == "true" || w == "false":
            nextToken()
            return .boolean(w == "true")
        case .keyword("undefined"):
            nextToken()
            return .undefined
        case .identifier(let name):
            nextToken()
            expr = .identifier(name)
        case .symbol("{"):
            return try parseObjectLiteral()
        case .symbol("["):
            return try parseArrayLiteral()
        default:
            print("Unexpected token: \(currentToken)")
            return .unknown
        }
        while true {
            switch currentToken {
            case .symbol("."):
                nextToken()
                guard case .identifier(let prop) = currentToken else {
                    throw .failedExpectation(expected: "", expectationNote: "property name after '.'", actual: "\(currentToken)")
                }
                nextToken()
                expr = .propertyAccess(object: expr, property: prop)
            case .symbol("("):
                expr = try parseCallExpression(callee: expr)
            case .symbol("="):
                let lhs = expr
                nextToken()
                expr = try .assignment(variable: lhs, value: parseExpression())
            case .symbol(let op) where JSLexer.compoundArithmeticTokens.contains(op):
                let lhs = expr
                nextToken()
                expr = try .compoundAssignment(operator: op, variable: lhs, value: parseExpression())
            default:
                return expr
            }
        }
        return expr
    }
}