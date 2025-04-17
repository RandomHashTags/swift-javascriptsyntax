public enum JSParseError : CustomStringConvertible, Error {
    case failedExpectation(expected: String, expectationNote: String? = nil, actual: String, index: Int)
    case cannotReadAfterEOF

    public var description : String {
        switch self {
        case .failedExpectation(let expected, let expectationNote, let actual, let index):
            var s = "Expected "
            if !expected.isEmpty {
                s += "'\(expected)'"
            }
            if let expectationNote {
                s += " " + expectationNote
            }
            s += " at index \(index)"
            return s + "; actual '\(actual)'"
        case .cannotReadAfterEOF:
            return "Tried reading token after end of file"
        }
    }
}