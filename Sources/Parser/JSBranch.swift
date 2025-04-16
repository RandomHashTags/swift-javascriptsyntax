public struct IfStatement {
    public let condition:JSExpr
    public let thenBranch:[JSStatement]
    public let elseBranch:[JSStatement]?
}