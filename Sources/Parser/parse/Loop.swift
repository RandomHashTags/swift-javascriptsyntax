extension JSParser {
    mutating func parseLoop() throws(JSParseError) -> JSStatement {
        var loopType:JSLoopType = .for
        switch currentToken {
        case .keyword("for"):
            loopType = .for
        case .keyword("while"):
            loopType = .while
        default:
            throw .failedExpectation(expected: "", expectationNote: "loop", actual: "\(currentToken)", index: index)
        }
        nextToken()
        guard currentToken == .symbol("(") else {
            throw .failedExpectation(expected: "(", expectationNote: "to open loop condition", actual: "\(currentToken)", index: index)
        }
        nextToken()
        var conditions:[JSSyntax] = []
        while currentToken != .symbol(")") {
            let syntax = try parseSyntax()
            //print("parseLoop;condition syntax=\(syntax)")
            conditions.append(syntax)
        }
        nextToken()
        guard currentToken == .symbol("{") else {
            throw .failedExpectation(expected: "{", expectationNote: "to open loop block", actual: "\(currentToken)", index: index)
        }
        nextToken()
        var block:[JSSyntax] = []
        while currentToken != .symbol("}") {
            let syntax = try parseSyntax()
            //print("parseLoop;block syntax=\(syntax)")
            block.append(syntax)
        }
        nextToken()
        return .loop(loopType: loopType, conditions: conditions, block: block)
    }
}