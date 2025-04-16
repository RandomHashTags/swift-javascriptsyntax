extension JSParser {
    mutating func parseKeyword() -> JSStatement? {
        guard case .keyword(let key) = currentToken else { return nil }
        switch key {
        case "let", "const", "var":
            let decl = parseVariableDeclarations()
            return .variables(decl)
        case "function":
            let decl = parseFunctionDeclaration()
            return .function(decl)
        case "return":
            skip()
            let value = parseExpression()
            guard currentToken == .symbol(";") else {
                print("Expected ';' after return; got \(currentToken)")
                return nil
            }
            skip()
            return .returnStatement(value)
        case "if":
            return .ifStatement(parseIfStatement())
        case "for", "while":
            return parseLoop()
        default:
            return nil
        }
    }
}