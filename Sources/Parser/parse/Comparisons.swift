extension JSParser {
    mutating func parseComparisons(first: JSExpr) throws(JSParseError) -> JSExpr {
        var comparisons:[JSExpr] = [first]
        while currentToken != .symbol(";") {
            try comparisons.append(parseExpression())
        }
        return comparisons.count == 1 ? first : .comparisons(comparisons)
    }
}

/*
extension JSParser {
    mutating func parseComparison() throws(JSParseError) -> JSExpr {
        let lhs = currentToken
        nextToken()
        guard currentToken == .symbol("=") else {
            throw .failedExpectation(expected: "=", actual: "\(currentToken)", index: index)
        }
        nextToken()
        guard currentToken == .symbol("=") else {
            throw .failedExpectation(expected: "=", expectationNote: "at least two equal symbols need to be present", actual: "\(currentToken)", index: index)
        }
        nextToken()
        if currentToken == .symbol("=") {
            nextToken()
            return .comparison(lhs: lhs, operation: "===", rhs: currentToken)
        }
        print("parseComparison;==;currentToken=\(currentToken)")
        return .comparison(lhs: lhs, operation: "==", rhs: currentToken)
    }
}*/