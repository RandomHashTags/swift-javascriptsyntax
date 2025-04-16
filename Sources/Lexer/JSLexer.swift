public struct JSLexer {
    public static let stringDelimiters:Set<Character> = ["\"", "'", "`"]
    public static let arithmeticTokens:Set<String> = ["+", "-", "*", "/"]
    public static let operatorPrecedence:[String:Int] = [
        "||": 1,
        "&&": 2,
        "==": 3, "!=": 3,
        "<": 4, ">": 4, "<=": 4, ">=": 4,
        "+": 5, "-": 5,
        "*": 6, "/": 6
    ]
    public static let unaryTokens:Set<Character> = ["!", "-", "+"]
    public static let symbols:Set<String> = arithmeticTokens.union(["{", "}", "(", ")", "[", "]", "=", ".", ",", ";", "<", ">", "<=", ">=", "&&", "||"])
    public static let variableDeclTokens:Set<String> = ["let", "const", "var"]
    public static let keywords:Set<String> = variableDeclTokens.union(["if", "function", "return", "for", "while"])
    public static let compoundArithmeticTokens:Set<String> = ["+=" , "-=", "*=", "/="]

    private let input:String
    private var index:String.Index

    public init(input: String) {
        self.input = input
        self.index = input.startIndex
    }

    public mutating func nextToken() -> JSToken {
        skipWhitespace()
        guard index < input.endIndex else {
            return .eof
        }

        let char = input[index]
        if char.isLetter {
            return readIdentifierOrKeyword()
        }
        if char.isNumber {
            return readNumber()
        }
        if Self.stringDelimiters.contains(char) {
            var string = ""
            skip()
            while index < input.endIndex && input[index] != char {
                string.append(input[index])
                skip()
            }
            skip()
            return .string(delimiter: char, string)
        }
        if Self.symbols.contains(String(char)) {
            skip()
            return .symbol(String(char))
        }
        return .eof
    }

    private mutating func skipWhitespace() {
        while index < input.endIndex && input[index].isWhitespace {
            skip()
        }
    }

    private mutating func skip() {
        input.formIndex(after: &index)
    }

    private mutating func readIdentifierOrKeyword() -> JSToken {
        var value = ""
        while index < input.endIndex && (input[index].isLetter || input[index] == "_") {
            value.append(input[index])
            skip()
        }
        if Self.keywords.contains(value) {
            return .keyword(value)
        }
        return .identifier(value)
    }

    private mutating func readNumber() -> JSToken {
        var value = ""
        while index < input.endIndex && input[index].isNumber {
            value.append(input[index])
            skip()
        }
        return .number(Double(value) ?? 0)
    }
}