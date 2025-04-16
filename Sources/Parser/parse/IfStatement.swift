extension JSParser {
    mutating func parseIfStatement() -> IfStatement {
        guard case .keyword("if") = currentToken else {
            fatalError("Expected 'keyword(\"if\")'; got \(currentToken)")
        }
        skip()
        guard case .symbol("(") = currentToken else {
            fatalError("Expected '(' after 'if'; got \(currentToken)")
        }
        skip()
        let condition = parseExpression()
        guard case .symbol(")") = currentToken else {
            fatalError("Expected ')' after condition; got \(currentToken)")
        }
        skip()
        guard case .symbol("{") = currentToken else {
            fatalError("Expected '{' to start 'if' block; got \(currentToken)")
        }
        skip()
        var block:[JSStatement] = []
        while currentToken != .symbol("}") {
            if let s = parseStatement() {
                block.append(s)
            } else {
                print("Invalid statement in 'if' block; got \(currentToken)")
                break
            }
        }
        guard case .symbol("}") = currentToken else {
            fatalError("Expected '}' to close 'if' block; got \(currentToken)")
        }
        skip()
        var elseBranch:[JSStatement]? = nil
        if case .keyword("else") = currentToken {
            skip()
            guard case .symbol("{") = currentToken else {
                fatalError("Expected '{' to start 'else' block; got \(currentToken)")
            }
            skip()
            var elses:[JSStatement] = []
            while currentToken != .symbol("}") {
                if let stmt = parseStatement() {
                    elses.append(stmt)
                } else {
                    print("Invalid statement in 'else' block")
                    break
                }
            }
            guard case .symbol("}") = currentToken else {
                fatalError("Expected '}' to close 'else' block; got \(currentToken)")
            }
            skip()
            elseBranch = elses
        }
        return IfStatement(condition: condition, thenBranch: block, elseBranch: elseBranch)
    }
}