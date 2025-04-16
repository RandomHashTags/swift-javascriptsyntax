extension JSParser {
    mutating func parseIfStatement() throws(JSParseError) -> IfStatement {
        guard currentToken == .keyword("if") else {
            throw .failedExpectation(expected: "keyword(\"if\")", actual: "\(currentToken)")
        }
        skip()
        guard currentToken == .symbol("(") else {
            throw .failedExpectation(expected: "(", expectationNote: "after 'if'", actual: "\(currentToken)")
        }
        skip()
        let condition = try parseExpression()
        guard currentToken == .symbol(")") else {
            throw .failedExpectation(expected: ")", expectationNote: "after condition", actual: "\(currentToken)")
        }
        skip()
        guard currentToken == .symbol("{") else {
            throw .failedExpectation(expected: "{", expectationNote: "to start 'if' block", actual: "\(currentToken)")
        }
        skip()
        var block:[JSStatement] = []
        while currentToken != .symbol("}") {
            if let s = try parseStatement() {
                block.append(s)
            } else {
                print("Invalid statement in 'if' block; got \(currentToken)")
                break
            }
        }
        guard currentToken == .symbol("}") else {
            throw .failedExpectation(expected: "}", expectationNote: "to close 'if' block", actual: "\(currentToken)")
        }
        skip()
        var elseBranch:[JSStatement]? = nil
        if case .keyword("else") = currentToken {
            skip()
            guard currentToken == .symbol("{") else {
                throw .failedExpectation(expected: "{", expectationNote: "to start 'else' block", actual: "\(currentToken)")
            }
            skip()
            var elses:[JSStatement] = []
            while currentToken != .symbol("}") {
                if let stmt = try parseStatement() {
                    elses.append(stmt)
                } else {
                    print("Invalid statement in 'else' block")
                    break
                }
            }
            guard currentToken == .symbol("}") else {
                throw .failedExpectation(expected: "}", expectationNote: "to close 'else' block", actual: "\(currentToken)")
            }
            skip()
            elseBranch = elses
        }
        return IfStatement(condition: condition, thenBranch: block, elseBranch: elseBranch)
    }
}