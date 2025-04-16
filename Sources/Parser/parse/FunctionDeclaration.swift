extension JSParser {
    mutating func parseFunctionDeclaration() throws(JSParseError) -> JSFunction {
        guard case .keyword("function") = currentToken else {
            throw .failedExpectation(expected: "", expectationNote: "keyword(\"function\")", actual: "\(currentToken)")
        }
        skip()
        guard case .identifier(let name) = currentToken else {
            throw .failedExpectation(expected: "", expectationNote: "function name", actual: "\(currentToken)")
        }
        skip()
        guard currentToken == .symbol("(") else {
            throw .failedExpectation(expected: "(", expectationNote: "after function name", actual: "\(currentToken)")
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
            throw .failedExpectation(expected: ")", expectationNote: "after parameters", actual: "\(currentToken)")
        }
        skip()
        guard currentToken == .symbol("{") else {
            throw .failedExpectation(expected: "{", expectationNote: "to start function body", actual: "\(currentToken)")
        }
        skip()
        var body:[JSFunction.BodyElement] = []
        while currentToken != .symbol("}") {
            if let s = try parseStatement() {
                body.append(.statement(s))
            } else {
                let expr = try parseExpression()
                body.append(.expression(expr))
                skip()
            }
        }
        guard currentToken == .symbol("}") else {
            throw .failedExpectation(expected: "}", expectationNote: "to close function body", actual: "\(currentToken)")
        }
        skip()
        return JSFunction(name: name, parameters: parameters, body: body)
    }
}