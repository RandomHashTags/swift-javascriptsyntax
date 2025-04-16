extension JSParser {
    mutating func parseObjectLiteral() throws(JSParseError) -> JSExpr {
        skip() // consume '{'
        var pairs:[String:JSExpr] = [:]
        while currentToken != .symbol("}") {
            guard case .identifier(let key) = currentToken else {
                throw .failedExpectation(expected: "", expectationNote: "identifier for object key", actual: "\(currentToken)")
            }
            skip()
            guard currentToken == .symbol(":") else {
                throw .failedExpectation(expected: ":", expectationNote: "after key", actual: "\(currentToken)")
            }
            skip()
            pairs[key] = try parseExpression()
            if currentToken == .symbol(",") {
                skip()
            } else {
                break
            }
        }
        guard currentToken == .symbol("}") else {
            throw .failedExpectation(expected: "}", expectationNote: "to close object literal", actual: "\(currentToken)")
        }
        skip()
        return .objectLiteral(pairs)
    }
}