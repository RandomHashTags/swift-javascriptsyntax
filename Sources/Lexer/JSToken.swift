public enum JSToken : Equatable {
    case number(Double)
    case identifier(String)
    case string(delimiter: Character, String)
    case keyword(String)
    case symbol(String)
    case eof
}