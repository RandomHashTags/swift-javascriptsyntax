extension JSParser {
    mutating func parseFunctionDeclaration() throws(JSParseError) -> JSFunction {
        guard case .keyword("function") = currentToken else {
            throw .failedExpectation(expected: "", expectationNote: "keyword(\"function\")", actual: "\(currentToken)")
        }
        nextToken()
        guard case .identifier(let name) = currentToken else {
            throw .failedExpectation(expected: "", expectationNote: "function name", actual: "\(currentToken)")
        }
        nextToken()
        guard currentToken == .symbol("(") else {
            throw .failedExpectation(expected: "(", expectationNote: "after function name", actual: "\(currentToken)")
        }
        nextToken()
        var parameters:[String] = []
        while case .identifier(let param) = currentToken {
            parameters.append(param)
            nextToken()
            if currentToken == .symbol(",") {
                nextToken()
            } else {
                break
            }
        }
        guard currentToken == .symbol(")") else {
            throw .failedExpectation(expected: ")", expectationNote: "after parameters", actual: "\(currentToken)")
        }
        nextToken()
        guard currentToken == .symbol("{") else {
            throw .failedExpectation(expected: "{", expectationNote: "to start function body", actual: "\(currentToken)")
        }
        nextToken()
        var body:[JSSyntax] = []
        while currentToken != .symbol("}") {
            if let s = try parseStatement() {
                body.append(.statement(s))
            } else {
                let expr = try parseExpression()
                body.append(.expression(expr))
                nextToken()
            }
        }
        guard currentToken == .symbol("}") else {
            throw .failedExpectation(expected: "}", expectationNote: "to close function body", actual: "\(currentToken)")
        }
        nextToken()
        return JSFunction(name: name, parameters: parameters, body: body)
    }
}