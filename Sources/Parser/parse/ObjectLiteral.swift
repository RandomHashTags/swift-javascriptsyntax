extension JSParser {
    mutating func parseObjectLiteral() -> JSExpr {
        skip() // consume '{'
        var pairs:[String:JSExpr] = [:]
        while currentToken != .symbol("}") {
            guard case .identifier(let key) = currentToken else {
                fatalError("Expected identifier for object key; got \(currentToken)")
            }
            skip()
            guard case .symbol(":") = currentToken else {
                fatalError("Expected ':' after key; got \(currentToken)")
            }
            skip()
            pairs[key] = parseExpression()
            if case .symbol(",") = currentToken {
                skip()
            } else {
                break
            }
        }
        guard case .symbol("}") = currentToken else {
            fatalError("Expected '}' to close object literal; got \(currentToken)")
        }
        skip()
        return .objectLiteral(pairs)
    }
}