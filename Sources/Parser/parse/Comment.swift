extension JSParser {
    mutating func parseComment() -> JSStatement? {
        guard currentToken == .symbol("/") else { return nil }
        let originalIndex = lexer.index
        lexer.skipWhitespace()
        guard let comment = parseSingleComment() ?? parseMultiLineComment() else {
            lexer.index = originalIndex
            return nil
        }
        skip()
        return comment
    }

    private mutating func parseSingleComment() -> JSStatement? {
        guard lexer.input[lexer.index] == "/" else {
            return nil
        }
        lexer.skip()
        var comment = ""
        var char = lexer.input[lexer.index]
        while char != "\n" {
            comment.append(char)
            lexer.skip()
            char = lexer.input[lexer.index]
        }
        return .comment(comment)
    }
    private mutating func parseMultiLineComment() -> JSStatement? {
        guard lexer.input[lexer.index] == "*" else {
            return nil
        }
        lexer.skip()
        var comment = ""
        var char = lexer.input[lexer.index]
        var nextIndex = lexer.input.index(after: lexer.index)
        while char != "*" && nextIndex < lexer.input.endIndex && lexer.input[nextIndex] != "/" {
            comment.append(char)
            lexer.skip()
            char = lexer.input[lexer.index]
            lexer.input.formIndex(after: &nextIndex)
        }
        lexer.skip()
        lexer.skip()
        return .multilineComment(comment)
    }
}