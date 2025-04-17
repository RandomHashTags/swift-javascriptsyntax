public indirect enum JSExpr : Sendable, Equatable {
    case unknown
    case undefined
    case null

    case number(Double)
    case identifier(String)
    case binaryOp(String, JSExpr, JSExpr)
    case call(callee: JSExpr, arguments: [JSExpr])
    case objectLiteral([String:JSExpr])
    case arrayLiteral([JSExpr])
    case string(String)
    case boolean(Bool)
    case unaryOp(String, JSExpr)
    case propertyAccess(object: JSExpr, property: String)
    case assignment(variable: JSExpr, value: JSExpr)
    case compoundAssignment(operator: String, variable: JSExpr, value: JSExpr)

    case comparison(lhs: JSExpr, operation: String, rhs: JSExpr)
    case comparisons([JSExpr])

    case logicalOperation(String)
    case bitwiseOperation(String)
}