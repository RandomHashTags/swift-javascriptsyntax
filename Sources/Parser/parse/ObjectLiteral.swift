extension JSParser {
    mutating func parseObjectLiteral() throws(JSParseError) -> JSExpr {
        nextToken() // consume '{'
        var pairs:[String:JSExpr] = [:]
        while currentToken != .symbol("}") {
            guard case .identifier(let key) = currentToken else {
                throw .failedExpectation(expected: "", expectationNote: "identifier for object key", actual: "\(currentToken)")
            }
            nextToken()
            guard currentToken == .symbol(":") else {
                throw .failedExpectation(expected: ":", expectationNote: "after key", actual: "\(currentToken)")
            }
            nextToken()
            pairs[key] = try parseExpression()
            if currentToken == .symbol(",") {
                nextToken()
            } else {
                break
            }
        }
        guard currentToken == .symbol("}") else {
            throw .failedExpectation(expected: "}", expectationNote: "to close object literal", actual: "\(currentToken)")
        }
        nextToken()
        return .objectLiteral(pairs)
    }
}