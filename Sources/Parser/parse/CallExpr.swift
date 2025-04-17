extension JSParser {
    mutating func parseCallExpression(callee: JSExpr) throws(JSParseError) -> JSExpr {
        guard currentToken == .symbol("(") else {
            throw .failedExpectation(expected: "(", actual: "\(currentToken)", index: index)
        }
        nextToken()
        var arguments:[JSExpr] = []
        if currentToken != .symbol(")") {
            while true {
                try arguments.append(parseExpression())
                if currentToken == .symbol(",") {
                    nextToken()
                } else {
                    break
                }
            }
        }
        guard currentToken == .symbol(")") else {
            throw .failedExpectation(expected: ")", expectationNote: "after arguments", actual: "\(currentToken)", index: index)
        }
        nextToken()
        return .call(callee: callee, arguments: arguments)
    }
}