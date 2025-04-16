public struct JSFunction : Sendable {
    public let name:String?
    public let parameters:[String]
    public let body:[JSSyntax]

    public init(name: String?, parameters: [String], body: [JSSyntax]) {
        self.name = name
        self.parameters = parameters
        self.body = body
    }
}