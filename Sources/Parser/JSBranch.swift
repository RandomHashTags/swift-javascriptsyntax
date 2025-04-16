public struct IfStatement : Sendable {
    public let condition:JSExpr
    public let thenBranch:[JSStatement]
    public let elseBranch:[JSStatement]?
}