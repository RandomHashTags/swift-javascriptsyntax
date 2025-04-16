extension JSParser {
    mutating func parseFunctionDeclaration() -> JSFunction {
        guard case .keyword("function") = currentToken else {
            fatalError("Expected keyword(\"function\"); got \(currentToken)")
        }
        skip()
        guard case .identifier(let name) = currentToken else {
            fatalError("Expected function name; got \(currentToken)")
        }
        skip()
        guard currentToken == .symbol("(") else {
            fatalError("Expected '(' after function name; got \(currentToken)")
        }
        skip()
        var parameters:[String] = []
        while case .identifier(let param) = currentToken {
            parameters.append(param)
            skip()
            if currentToken == .symbol(",") {
                skip()
            } else {
                break
            }
        }
        guard currentToken == .symbol(")") else {
            fatalError("Expected ')' after parameters; got \(currentToken)")
        }
        skip()
        guard currentToken == .symbol("{") else {
            fatalError("Expected '{' to start function body; got \(currentToken)")
        }
        skip()
        var body:[JSFunction.BodyElement] = []
        while currentToken != .symbol("}") {
            if let s = parseStatement() {
                body.append(.statement(s))
            } else {
                let expr = parseExpression()
                body.append(.expression(expr))
                skip()
            }
        }
        guard currentToken == .symbol("}") else {
            fatalError("Expected '}' to close function body; got \(currentToken)")
        }
        skip()
        return JSFunction(name: name, parameters: parameters, body: body)
    }
}