import Lexer

extension JSParser {
    mutating func parsePrimary() -> JSExpr {
        var expr:JSExpr
        switch currentToken {
        case .number(let value):
            skip()
            expr = .number(value)
        case .string(_, let value):
            skip()
            return .string(value)
        case .keyword(let w) where w == "true" || w == "false":
            skip()
            return .boolean(w == "true")
        case .keyword("undefined"):
            skip()
            return .undefined
        case .identifier(let name):
            skip()
            expr = .identifier(name)
        case .symbol("{"):
            return parseObjectLiteral()
        case .symbol("["):
            return parseArrayLiteral()
        default:
            print("Unexpected token: \(currentToken)")
            return .unknown
        }
        while true {
            switch currentToken {
            case .symbol("."):
                skip()
                guard case .identifier(let prop) = currentToken else {
                    fatalError("Expected property name after '.'; got \(currentToken)")
                }
                skip()
                expr = .propertyAccess(object: expr, property: prop)
            case .symbol("("):
                expr = parseCallExpression(callee: expr)
            case .symbol("="):
                let lhs = expr
                skip()
                expr = .assignment(variable: lhs, value: parseExpression())
            case .symbol(let op) where JSLexer.compoundArithmeticTokens.contains(op):
                let lhs = expr
                skip()
                expr = .compoundAssignment(operator: op, variable: lhs, value: parseExpression())
            default:
                return expr
            }
        }
        return expr
    }
}