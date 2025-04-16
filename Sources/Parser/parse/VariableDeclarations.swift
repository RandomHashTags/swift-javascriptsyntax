import Lexer

extension JSParser {
    mutating func parseVariableDeclarations() -> [JSVariable] {
        guard case .keyword(let keyword) = currentToken, JSLexer.variableDeclTokens.contains(keyword) else {
            fatalError("Expected variable decl token; got \(currentToken)")
        }
        skip()
        guard let variables = parseVariableDeclarationsWithoutKeyword() else {
            fatalError("Expected variable decl; got \(currentToken)")
        }
        guard currentToken == .symbol(";") else {
            fatalError("Expected ';' after expression; got \(currentToken)")
        }
        skip()
        return variables
    }
    mutating func parseVariableDeclarationsWithoutKeyword() -> [JSVariable]? {
        guard case .identifier(let name) = currentToken else {
            fatalError("Expected identifier after keyword; got \(currentToken)")
        }
        skip()
        guard currentToken == .symbol("=") else {
            print("Expected '=' after identifier; got \(currentToken)")
            return nil
        }
        skip()
        let expr = parseExpression()
        var variables:[JSVariable] = [JSVariable(name: name, value: expr)]
        while currentToken == .symbol(",") {
            skip()
            if let additionalVariables = parseVariableDeclarationsWithoutKeyword() {
                variables.append(contentsOf: additionalVariables)
            }
        }
        return variables
    }
}