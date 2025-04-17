public enum JSParseError : CustomStringConvertible, Error {
    case failedExpectation(expected: String, expectationNote: String? = nil, actual: String)
    case cannotReadAfterEOF

    public var description : String {
        switch self {
        case .failedExpectation(let expected, let expectationNote, let actual):
            var s = "Expected "
            if !expected.isEmpty {
                s += "'\(expected)'"
            }
            if let expectationNote {
                s += " " + expectationNote
            }
            return s + "; actual '\(actual)'"
        case .cannotReadAfterEOF:
            return "Tried reading token after end of file"
        }
    }
}