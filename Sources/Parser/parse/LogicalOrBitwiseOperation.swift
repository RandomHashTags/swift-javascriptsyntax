extension JSParser {
    mutating func parseLogicalOrBitwiseOperation() throws(JSParseError) -> JSExpr {
        guard case .symbol(let s) = currentToken else {
            throw .failedExpectation(expected: "", expectationNote: "symbol", actual: "\(currentToken)", index: index)
        }
        let originalToken = currentToken
        var operation:JSExpr = .bitwiseOperation(s)
        switch s {
        case "|", "&":
            break
        default:
            throw .failedExpectation(expected: "", expectationNote: "logical or bitwise operation", actual: "\(currentToken)", index: index)
        }
        nextToken()
        if currentToken == originalToken {
            nextToken()
            operation = .logicalOperation(s + s)
        }
        return operation
    }
}