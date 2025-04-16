public enum JSStatement {
    case variables([JSVariable])
    case function(JSFunction)
    case returnStatement(JSExpr)
    case ifStatement(IfStatement)
    case loop(JSLoopType, JSExpr)
    case comment(String)
    case multilineComment(String)
}