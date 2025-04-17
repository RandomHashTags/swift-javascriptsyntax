public enum JSStatement : Sendable {
    case variables([JSVariable])
    case function(JSFunction)
    case returnStatement(JSExpr)
    case ifStatement(IfStatement)
    case loop(loopType: JSLoopType, conditions: [JSSyntax], block: [JSSyntax])

    case comment(String)
    case blockComment(String)
    case hashbangComment(String)
}