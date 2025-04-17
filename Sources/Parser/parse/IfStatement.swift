extension JSParser {
    mutating func parseIfStatement() throws(JSParseError) -> IfStatement {
        guard currentToken == .keyword("if") else {
            throw .failedExpectation(expected: "keyword(\"if\")", actual: "\(currentToken)")
        }
        nextToken()
        guard currentToken == .symbol("(") else {
            throw .failedExpectation(expected: "(", expectationNote: "after 'if'", actual: "\(currentToken)")
        }
        nextToken()
        let condition = try parseExpression()
        guard currentToken == .symbol(")") else {
            throw .failedExpectation(expected: ")", expectationNote: "after condition", actual: "\(currentToken)")
        }
        nextToken()
        guard currentToken == .symbol("{") else {
            throw .failedExpectation(expected: "{", expectationNote: "to start 'if' block", actual: "\(currentToken)")
        }
        nextToken()
        var block:[JSSyntax] = []
        while currentToken != .symbol("}") {
            try block.append(parseSyntax())
        }
        guard currentToken == .symbol("}") else {
            throw .failedExpectation(expected: "}", expectationNote: "to close 'if' block", actual: "\(currentToken)")
        }
        nextToken()
        var elseBranch:[JSSyntax]? = nil
        if currentToken == .keyword("else") {
            nextToken()
            guard currentToken == .symbol("{") else {
                throw .failedExpectation(expected: "{", expectationNote: "to start 'else' block", actual: "\(currentToken)")
            }
            nextToken()
            var elses:[JSSyntax] = []
            while currentToken != .symbol("}") {
                try elses.append(parseSyntax())
            }
            guard currentToken == .symbol("}") else {
                throw .failedExpectation(expected: "}", expectationNote: "to close 'else' block", actual: "\(currentToken)")
            }
            nextToken()
            elseBranch = elses
        }
        return IfStatement(condition: condition, thenBranch: block, elseBranch: elseBranch)
    }
}