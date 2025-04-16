extension JSParser {
    mutating func parseCallExpression(callee: JSExpr) -> JSExpr {
        guard currentToken == .symbol("(") else {
            fatalError("Expected '('; got \(currentToken)")
        }
        skip()
        var arguments:[JSExpr] = []
        if currentToken != .symbol(")") {
            while true {
                arguments.append(parseExpression())
                if currentToken == .symbol(",") {
                    skip()
                } else {
                    break
                }
            }
        }
        guard currentToken == .symbol(")") else {
            fatalError("Expected ')' after arguments; got \(currentToken)")
        }
        skip()
        return .call(callee: callee, arguments: arguments)
    }
}