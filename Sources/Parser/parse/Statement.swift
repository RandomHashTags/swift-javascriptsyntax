extension JSParser {
    mutating func parseStatement() -> JSStatement? {
        return parseKeyword() ?? parseSymbol()
    }
}