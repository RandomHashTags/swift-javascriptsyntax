extension JSParser {
    mutating func parseArrayLiteral() -> JSExpr {
        guard currentToken == .symbol("[") else {
            fatalError("Expected '[' to open array; got \(currentToken)")
        }
        skip() // consume '['
        var elements:[JSExpr] = []
        while currentToken != .symbol("]") {
            elements.append(parseExpression())
            if currentToken == .symbol(",") {
                skip()
            } else {
                break
            }
        }
        guard currentToken == .symbol("]") else {
            fatalError("Expected ']' to close array; got \(currentToken)")
        }
        skip()
        return .arrayLiteral(elements)
    }
}