public struct JSFunction : Sendable {
    public let name:String?
    public let parameters:[String]
    public let body:[BodyElement]

    public init(name: String?, parameters: [String], body: [BodyElement]) {
        self.name = name
        self.parameters = parameters
        self.body = body
    }
}

extension JSFunction {
    public enum BodyElement : Sendable {
        case statement(JSStatement)
        case expression(JSExpr)
    }
}
