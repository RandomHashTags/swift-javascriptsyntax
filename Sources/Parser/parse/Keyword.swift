extension JSParser {
    mutating func parseKeyword() throws(JSParseError) -> JSStatement? {
        guard case .keyword(let key) = currentToken else { return nil }
        switch key {
        case "let", "const", "var":
            let decl = try parseVariableDeclarations()
            return .variables(decl)
        case "function":
            let decl = try parseFunctionDeclaration()
            return .function(decl)
        case "return":
            nextToken()
            let value = try parseExpression()
            guard currentToken == .symbol(";") else {
                throw .failedExpectation(expected: ";", expectationNote: "after return", actual: "\(currentToken)", index: index)
            }
            nextToken()
            return .returnStatement(value)
        case "if":
            return try .ifStatement(parseIfStatement())
        case "for", "while":
            return try parseLoop()
        default:
            return nil
        }
    }
}