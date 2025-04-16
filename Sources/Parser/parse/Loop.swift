extension JSParser {
    mutating func parseLoop() -> JSStatement {
        var loopType:JSLoopType = .for
        switch currentToken {
        case .keyword("for"):
            loopType = .for
        case .keyword("while"):
            loopType = .while
        default:
            fatalError("Expected loop; got \(currentToken)")
        }
        skip()
        guard currentToken == .symbol("(") else {
            fatalError("Expected '(' to open loop; got \(currentToken)")
        }
        skip()
        var expr:JSExpr = .unknown
        return .loop(loopType, expr)
    }
}