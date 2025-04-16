extension JSParser {
    mutating func parseArrayLiteral() throws(JSParseError) -> JSExpr {
        guard currentToken == .symbol("[") else {
            throw .failedExpectation(expected: "[", expectationNote: "to open array", actual: "\(currentToken)")
        }
        skip()
        var elements:[JSExpr] = []
        while currentToken != .symbol("]") {
            try elements.append(parseExpression())
            if currentToken == .symbol(",") {
                skip()
            } else {
                break
            }
        }
        guard currentToken == .symbol("]") else {
            throw .failedExpectation(expected: "]", expectationNote: "to close array", actual: "\(currentToken)")
        }
        skip()
        return .arrayLiteral(elements)
    }
}