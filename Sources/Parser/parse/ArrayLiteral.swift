extension JSParser {
    mutating func parseArrayLiteral() -> JSExpr {
        guard currentToken == .symbol("[") else {
            fatalError("Expected '[' to open array; got \(currentToken)")
        }
        skip() // consume '['
        var elements:[JSExpr] = []
        while currentToken != .symbol("]") {
            elements.append(parseExpression())
            if case .symbol(",") = currentToken {
                skip()
            } else {
                break
            }
        }
        guard case .symbol("]") = currentToken else {
            fatalError("Expected ']' to close array; got \(currentToken)")
        }
        skip()
        return .arrayLiteral(elements)
    }
}