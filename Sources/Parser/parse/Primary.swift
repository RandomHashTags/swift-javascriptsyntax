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
        case .keyword("null"):
            nextToken()
            return .null
        case .keyword("of"):
            nextToken()
            return .identifier("of")
        case .identifier(let name):
            nextToken()
            expr = .identifier(name)
        case .symbol("{"):
            return try parseObjectLiteral()
        case .symbol("["):
            return try parseArrayLiteral()
        case .symbol("|"), .symbol("&"):
            return try parseLogicalOrBitwiseOperation()
        default:
            if currentToken == .eof {
                throw .cannotReadAfterEOF
            }
            print("Unexpected token at index \(lexer.input.distance(from: lexer.input.startIndex, to: lexer.index)): \(currentToken)")
            nextToken()
            return .unknown
        }
        while true {
            switch currentToken {
            case .symbol("."):
                nextToken()
                guard case .identifier(let prop) = currentToken else {
                    throw .failedExpectation(expected: "", expectationNote: "property name after '.'", actual: "\(currentToken)", index: index)
                }
                nextToken()
                expr = .propertyAccess(object: expr, property: prop)
            case .symbol("("):
                expr = try parseCallExpression(callee: expr)
            case .symbol("="):
                let lhs = expr
                expr = try parseAssignmentOrComparison(expr: lhs)
                if case .comparison = expr {
                    let v = expr
                    expr = try parseComparisons(first: v)
                }
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