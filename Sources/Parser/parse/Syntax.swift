extension JSParser {
    mutating func parseSyntax() throws(JSParseError) -> JSSyntax {
        if let s = try parseStatement() {
            return .statement(s)
        }
        return try .expression(parseExpression())
    }
}