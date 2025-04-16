public enum JSStatement : Sendable {
    case variables([JSVariable])
    case function(JSFunction)
    case returnStatement(JSExpr)
    case ifStatement(IfStatement)
    case loop(JSLoopType, JSExpr)

    case comment(String)
    case blockComment(String)
    case hashbangComment(String)
}