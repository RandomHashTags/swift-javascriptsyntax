public enum JSToken : Equatable, Sendable {
    case number(Double)
    case exponential(number: Int, exponent: Int)
    case binary(String)
    case octal(String)
    case hexadecimal(String)
    case bigIntLiteral(String)

    case identifier(String)
    case string(delimiter: Character, String)
    case keyword(String)
    case symbol(String)
    case eof
}