extension JSParser {
    mutating func parseAssignmentOrComparison(expr: JSExpr) throws(JSParseError) -> JSExpr {
        guard currentToken == .symbol("=") else {
            throw .failedExpectation(expected: "=", actual: "\(currentToken)", index: index)
        }
        nextToken()
        if currentToken == .symbol("=") {
            nextToken()
            if currentToken == .symbol("=") {
                nextToken()
                return try .comparison(lhs: expr, operation: "===", rhs: parseExpression())
            }
            return try .comparison(lhs: expr, operation: "==", rhs: parseExpression())
        }
        return try parseAssignment(expr: expr)
    }
}

extension JSParser {
    mutating func parseAssignment(expr: JSExpr) throws(JSParseError) -> JSExpr {
        let e = try JSExpr.assignment(variable: expr, value: parseExpression())
        if currentToken == .symbol(";") {
            nextToken()
        }
        return e
    }
}