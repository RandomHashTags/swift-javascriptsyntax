public struct JSSourceCode : Sendable {
    var syntax:[JSSyntax]

    public init(syntax: [JSSyntax] = []) {
        self.syntax = []
    }

    public mutating func append(_ source: JSSourceCode) {
        syntax.append(contentsOf: source.syntax)
    }
}