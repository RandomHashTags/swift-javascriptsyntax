public enum JSStatement {
    case variables([JSVariable])
    case function(JSFunction)
    case returnStatement(JSExpr)
    case ifStatement(IfStatement)
}