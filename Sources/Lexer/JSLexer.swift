// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Lexical_grammar
public struct JSLexer : Sendable {
    public static let stringDelimiters:Set<Character> = ["\"", "'", "`"]
    public static let arithmeticTokens:Set<String> = ["+", "-", "*", "/", "%"]
    public static let operatorPrecedence:[String:Int] = [
        "||": 1,
        "&&": 2,
        "==": 3, "!=": 3,
        "<": 4, ">": 4, "<=": 4, ">=": 4,
        "+": 5, "-": 5,
        "*": 6, "/": 6
    ]
    public static let unaryTokens:Set<Character> = ["!", "-", "+"]
    public static let symbols:Set<String> = arithmeticTokens.union(["{", "}", "(", ")", "[", "]", "=", ".", ",", ";", "<", ">", "<=", ">=", "&", "|", "#", "?", ":"])
    public static let variableDeclTokens:Set<String> = ["let", "const", "var"]
    public static let keywords:Set<String> = [
        "arguments", "async", "await",
        "break",
        "case", "catch", "class", "const", "continue",
        "debugger", "default", "delete", "do",
        "else", "enum", "eval", "export", "extends",
        "false", "finally", "for", "function",
        "if", "implements", "import", "in", "instanceof", "interface",
        "let",
        "new", "null",
        "of",
        "package", "private", "protected", "public",
        "return",
        "static", "super", "switch",
        "this", "throw", "true", "try", "typeof",
        "var", "void",
        "while", "with",
        "yield",
        "undefined"
    ]
    public static let compoundArithmeticTokens:Set<String> = ["+=" , "-=", "*=", "/="]

    public let input:String
    public var index:String.Index

    public init(input: String) {
        self.input = input
        self.index = input.startIndex
    }

    /// Skips leading whitespace and returns the next found JSToken.
    @inlinable
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
            nextIndex()
            while index < input.endIndex && input[index] != char {
                string.append(input[index])
                nextIndex()
            }
            nextIndex()
            return .string(delimiter: char, string)
        }
        if Self.symbols.contains(String(char)) {
            nextIndex()
            return .symbol(String(char))
        }
        return .eof
    }

    /// Assigns the `index` to the next non-whitespace character's index.
    @inlinable
    public mutating func skipWhitespace() {
        while index < input.endIndex && input[index].isWhitespace {
            nextIndex()
        }
    }

    /// Increments the `index` by one.
    @inlinable
    public mutating func nextIndex() {
        input.formIndex(after: &index)
    }

    @inlinable
    public mutating func readIdentifierOrKeyword() -> JSToken {
        var value = ""
        while index < input.endIndex && (input[index].isLetter || input[index] == "_") {
            value.append(input[index])
            nextIndex()
        }
        if Self.keywords.contains(value) {
            return .keyword(value)
        }
        return .identifier(value)
    }

    @inlinable
    public mutating func readNumber() -> JSToken {
        // TODO: try to parse a more accurate JSToken other than just `number`
        var value = ""
        while index < input.endIndex && input[index].isNumber {
            value.append(input[index])
            nextIndex()
        }
        return .number(Double(value) ?? 0)
    }
}