extension JSParser {
    mutating func parseObjectLiteral() throws(JSParseError) -> JSExpr {
        nextToken() // consume '{'
        var pairs:[String:JSExpr] = [:]
        while currentToken != .symbol("}") {
            guard case .identifier(let key) = currentToken else {
                throw .failedExpectation(expected: "", expectationNote: "identifier for object literal key", actual: "\(currentToken)", index: index)
            }
            nextToken()
            guard currentToken == .symbol(":") else {
                throw .failedExpectation(expected: ":", expectationNote: "after key while parsing object literal", actual: "\(currentToken)", index: index)
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
            throw .failedExpectation(expected: "}", expectationNote: "to close object literal", actual: "\(currentToken)", index: index)
        }
        nextToken()
        return .objectLiteral(pairs)
    }
}