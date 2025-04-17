public struct IfStatement : Sendable {
    public let condition:JSExpr
    public let thenBranch:[JSSyntax]
    public let elseBranch:[JSSyntax]?
}