extension JSParser {
    mutating func parseSymbol() -> JSStatement? {
        guard case .symbol(let key) = currentToken else { return nil }
        switch key {
        case "/", "#":
            return parseComment()
        default:
            return nil
        }
    }
}