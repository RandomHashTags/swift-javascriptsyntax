extension JSParser {
    mutating func parseIfStatement() throws(JSParseError) -> IfStatement {
        guard currentToken == .keyword("if") else {
            throw .failedExpectation(expected: "keyword(\"if\")", actual: "\(currentToken)", index: index)
        }
        nextToken()
        guard currentToken == .symbol("(") else {
            throw .failedExpectation(expected: "(", expectationNote: "after 'if'", actual: "\(currentToken)", index: index)
        }
        nextToken()
        let condition = try parseExpression()
        guard currentToken == .symbol(")") else {
            throw .failedExpectation(expected: ")", expectationNote: "after 'if' condition", actual: "\(currentToken)", index: index)
        }
        nextToken()
        guard currentToken == .symbol("{") else {
            throw .failedExpectation(expected: "{", expectationNote: "to start 'if' block", actual: "\(currentToken)", index: index)
        }
        nextToken()
        var block:[JSSyntax] = []
        while currentToken != .symbol("}") {
            try block.append(parseSyntax())
        }
        guard currentToken == .symbol("}") else {
            throw .failedExpectation(expected: "}", expectationNote: "to close 'if' block", actual: "\(currentToken)", index: index)
        }
        nextToken()
        var elseBranch:[JSSyntax]? = nil
        if currentToken == .keyword("else") {
            nextToken()
            guard currentToken == .symbol("{") else {
                throw .failedExpectation(expected: "{", expectationNote: "to start 'else' block", actual: "\(currentToken)", index: index)
            }
            nextToken()
            var elses:[JSSyntax] = []
            while currentToken != .symbol("}") {
                try elses.append(parseSyntax())
            }
            guard currentToken == .symbol("}") else {
                throw .failedExpectation(expected: "}", expectationNote: "to close 'else' block", actual: "\(currentToken)", index: index)
            }
            nextToken()
            elseBranch = elses
        }
        return IfStatement(condition: condition, thenBranch: block, elseBranch: elseBranch)
    }
}