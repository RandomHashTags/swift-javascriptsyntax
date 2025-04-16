extension JSParser {
    mutating func parseLoop() throws(JSParseError) -> JSStatement {
        var loopType:JSLoopType = .for
        switch currentToken {
        case .keyword("for"):
            loopType = .for
        case .keyword("while"):
            loopType = .while
        default:
            throw .failedExpectation(expected: "", expectationNote: "loop", actual: "\(currentToken)")
        }
        skip()
        guard currentToken == .symbol("(") else {
            throw .failedExpectation(expected: "(", expectationNote: "to open loop", actual: "\(currentToken)")
        }
        skip()
        var expr:JSExpr = .unknown
        return .loop(loopType, expr)
    }
}