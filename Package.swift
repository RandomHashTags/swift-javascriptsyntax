// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "swift-javascriptparser",
    products: [
        .library(
            name: "JavaScriptLexer",
            targets: ["Lexer"]
        ),
        .library(
            name: "JavaScriptParser",
            targets: ["Parser"]
        ),
        .library(
            name: "JavaScriptInterpreter",
            targets: ["Interpreter"]
        ),
    ],
    targets: [
        .target(name: "Lexer"),
        .target(name: "Parser", dependencies: ["Lexer"]),
        .target(name: "Interpreter", dependencies: ["Lexer", "Parser"]),
        .testTarget(
            name: "ParserTests",
            dependencies: ["Parser"]
        ),
    ]
)
