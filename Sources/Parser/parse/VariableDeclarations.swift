import Lexer

extension JSParser {
    mutating func parseVariableDeclarations() throws(JSParseError) -> [JSVariable] {
        guard case .keyword(let keyword) = currentToken, JSLexer.variableDeclTokens.contains(keyword) else {
            throw .failedExpectation(expected: "", expectationNote: "variable decl token", actual: "\(currentToken)")
        }
        skip()
        guard let variables = try parseVariableDeclarationsWithoutKeyword() else {
            throw .failedExpectation(expected: "", expectationNote: "variable decl", actual: "\(currentToken)")
        }
        guard currentToken == .symbol(";") else {
            throw .failedExpectation(expected: ";", expectationNote: "after expression", actual: "\(currentToken)")
        }
        skip()
        return variables
    }

    private mutating func parseVariableDeclarationsWithoutKeyword() throws(JSParseError) -> [JSVariable]? {
        guard case .identifier(let name) = currentToken else {
            throw .failedExpectation(expected: "", expectationNote: "identifier after keyword", actual: "\(currentToken)")
        }
        skip()
        guard currentToken == .symbol("=") else {
            print("Expected '=' after identifier; got \(currentToken)")
            return nil
        }
        skip()
        let expr = try parseExpression()
        var variables:[JSVariable] = [JSVariable(name: name, value: expr)]
        while currentToken == .symbol(",") {
            skip()
            if let additionalVariables = try parseVariableDeclarationsWithoutKeyword() {
                variables.append(contentsOf: additionalVariables)
            }
        }
        return variables
    }
}