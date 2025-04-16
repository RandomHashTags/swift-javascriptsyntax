extension JSParser {
    mutating func parseStatement() throws(JSParseError) -> JSStatement? {
        return try parseKeyword() ?? parseSymbol()
    }
}