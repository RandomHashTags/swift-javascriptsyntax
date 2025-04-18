extension JSParser {
    mutating func parseComment() -> JSStatement? {
        let originalIndex = lexer.index
        switch currentToken {
        case .symbol("/"):
            break
        case .symbol("#"):
            guard let c = parseHashbangComment(originalIndex: originalIndex) else { return nil }
            nextToken()
            return c
        default:
            return nil
        }
        lexer.skipWhitespace()
        guard let comment = parseSingleComment() ?? parseBlockComment() else {
            lexer.index = originalIndex
            return nil
        }
        nextToken()
        return comment
    }

    private mutating func parseSingleComment() -> JSStatement? {
        guard lexer.input[lexer.index] == "/" else { return nil }
        var comment = ""
        parseComment(comment: &comment)
        return .comment(comment)
    }
    private mutating func parseComment(comment: inout String) {
        lexer.nextIndex()
        var char = lexer.input[lexer.index]
        while char != "\n" {
            comment.append(char)
            lexer.nextIndex()
            char = lexer.input[lexer.index]
        }
    }
    private mutating func parseBlockComment() -> JSStatement? {
        guard lexer.input[lexer.index] == "*" else { return nil }
        lexer.nextIndex()
        var comment = ""
        var char = lexer.input[lexer.index]
        var nextIndex = lexer.input.index(after: lexer.index)
        while char != "*" && nextIndex < lexer.input.endIndex && lexer.input[nextIndex] != "/" {
            comment.append(char)
            lexer.nextIndex()
            char = lexer.input[lexer.index]
            lexer.input.formIndex(after: &nextIndex)
        }
        lexer.nextIndex()
        lexer.nextIndex()
        return .blockComment(comment)
    }
    private mutating func parseHashbangComment(originalIndex: String.Index) -> JSStatement? {
        guard lexer.index < lexer.input.endIndex && lexer.input[lexer.index] == "!" else {
            lexer.index = originalIndex
            return nil
        }
        var comment = ""
        parseComment(comment: &comment)
        return .hashbangComment(comment)
    }
}