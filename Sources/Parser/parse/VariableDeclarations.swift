import Lexer

extension JSParser {
    mutating func parseVariableDeclarations() throws(JSParseError) -> [JSVariable] {
        guard case .keyword(let keyword) = currentToken, JSLexer.variableDeclTokens.contains(keyword) else {
            throw .failedExpectation(expected: "", expectationNote: "variable declaration token", actual: "\(currentToken)", index: index)
        }
        nextToken()
        guard let variables = try parseVariableDeclarationsWithoutKeyword() else {
            throw .failedExpectation(expected: "", expectationNote: "variable declaration", actual: "\(currentToken)", index: index)
        }
        guard currentToken == .symbol(";") else {
            throw .failedExpectation(expected: ";", expectationNote: "after variable declaration expression", actual: "\(currentToken)", index: index)
        }
        nextToken()
        return variables
    }

    private mutating func parseVariableDeclarationsWithoutKeyword() throws(JSParseError) -> [JSVariable]? {
        guard case .identifier(let name) = currentToken else {
            throw .failedExpectation(expected: "", expectationNote: "identifier after keyword", actual: "\(currentToken)", index: index)
        }
        nextToken()
        guard currentToken == .symbol("=") else {
            throw .failedExpectation(expected: "=", expectationNote: "after variable declaration identifier", actual: "\(currentToken)", index: index)
        }
        nextToken()
        let expr = try parseExpression()
        var variables:[JSVariable] = [JSVariable(name: name, value: expr)]
        while currentToken == .symbol(",") {
            nextToken()
            if let additionalVariables = try parseVariableDeclarationsWithoutKeyword() {
                variables.append(contentsOf: additionalVariables)
            }
        }
        return variables
    }
}