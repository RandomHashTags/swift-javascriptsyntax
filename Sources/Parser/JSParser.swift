//
//  JSParser.swift
//
//
//  Created by Evan Anderson on 8/15/24.
//

import Lexer

// the endgame for this feature is to replace the minification logic with this, enabling more
// features like more effective compression, obfuscation, renaming declarations (further minifying the contents), and uglification
public struct JSParser {
    public static func parse(_ string: String) {
        var parser = JSParser(input: string)
        while parser.currentToken != .eof {
            if let statement = parser.parseStatement() {
                print("statement=\(statement)")
            } else {
                print("\(parser.currentToken)")
                parser.skip()
            }
        }
    }

    private var lexer:JSLexer
    private var currentToken:JSToken
    
    public init(input: String) {
        self.lexer = JSLexer(input: input)
        self.currentToken = lexer.nextToken()
    }

    private mutating func skip() {
        currentToken = lexer.nextToken()
    }
}

// MARK: Expression
extension JSParser {
    private mutating func parseExpression(precedence minPrec: Int = 0) -> JSExpr {
        var expr = parseUnary()
        if case .symbol(let op) = currentToken, JSLexer.compoundArithmeticTokens.contains(op) {
            let lhs = expr
            skip()
            return .compoundAssignment(operator: op, variable: lhs, value: parseExpression())
        }
        if case .symbol("=") = currentToken {
            let lhs = expr
            skip()
            return .assignment(variable: lhs, value: parseExpression())
        }
        while case .symbol(let op) = currentToken, let opPrec = JSLexer.operatorPrecedence[op], opPrec >= minPrec {
            skip()
            var rhs = parseUnary()
            while case .symbol(let nextOp) = currentToken,
                    let nextPrec = JSLexer.operatorPrecedence[nextOp],
                    nextPrec > opPrec {
                rhs = parseExpression(precedence: nextPrec)
            }
            expr = .binaryOp(op, expr, rhs)
        }
        return expr
    }

    private mutating func parsePrimary() -> JSExpr {
        var expr:JSExpr
        switch currentToken {
        case .number(let value):
            skip()
            expr = .number(value)
        case .string(let delimiter, let value):
            skip()
            return .string(value)
        case .keyword(let w) where w == "true" || w == "false":
            skip()
            return .boolean(w == "true")
        case .identifier(let name):
            skip()
            expr = .identifier(name)
        case .symbol("{"):
            return parseObjectLiteral()
        case .symbol("["):
            return parseArrayLiteral()
        default:
            print("Unexpected token: \(currentToken)")
            return .unknown
        }
        while true {
            switch currentToken {
            case .symbol("."):
                skip()
                guard case .identifier(let prop) = currentToken else {
                    fatalError("Expected property name after '.'; got \(currentToken)")
                }
                skip()
                expr = .propertyAccess(object: expr, property: prop)
            case .symbol("("):
                expr = parseCallExpression(callee: expr)
            case .symbol("="):
                let lhs = expr
                skip()
                expr = .assignment(variable: lhs, value: parseExpression())
            case .symbol(let op) where JSLexer.compoundArithmeticTokens.contains(op):
                let lhs = expr
                skip()
                expr = .compoundAssignment(operator: op, variable: lhs, value: parseExpression())
            default:
                return expr
            }
        }
        return expr
    }
}

// MARK: Statement
extension JSParser {
    mutating func parseStatement() -> JSStatement? {
        switch currentToken {
        case .keyword("let"), .keyword("const"), .keyword("var"):
            if let decl = parseVariableDeclarations() {
                return .variables(decl)
            }
        case .keyword("function"):
            if let decl = parseFunctionDeclaration() {
                return .function(decl)
            }
        case .keyword("return"):
            skip()
            let value = parseExpression()
            guard case .symbol(";") = currentToken else {
                print("Expected ';' after return; got \(currentToken)")
                return nil
            }
            skip()
            return .returnStatement(value)
        case .keyword("if"):
            if let ifStmt = parseIfStatement() {
                return .ifStatement(ifStmt)
            }
        default:
            break
        }
        return nil
    }
}

extension JSParser {
    private mutating func parseCallExpression(callee: JSExpr) -> JSExpr {
        skip() // consume '('
        var arguments:[JSExpr] = []
        if currentToken != .symbol(")") {
            while true {
                arguments.append(parseExpression())
                if case .symbol(",") = currentToken {
                    skip()
                } else {
                    break
                }
            }
        }
        guard case .symbol(")") = currentToken else {
            fatalError("Expected ')' after arguments; got \(currentToken)")
        }
        skip()
        return .call(callee: callee, arguments: arguments)
    }
}

// MARK: Variable decl
extension JSParser {
    mutating func parseVariableDeclarations() -> [JSVariable]? {
        guard case .keyword(let keyword) = currentToken, JSLexer.variableDeclTokens.contains(keyword) else {
            return nil
        }
        skip()
        guard let variables = parseVariableDeclarationsWithoutKeyword() else { return nil }
        guard case .symbol(";") = currentToken else {
            print("Expected ';' after expression; got \(currentToken)")
            return nil
        }
        skip()
        return variables
    }
    mutating func parseVariableDeclarationsWithoutKeyword() -> [JSVariable]? {
        guard case .identifier(let name) = currentToken else {
            print("Expected identifier after keyword; got \(currentToken)")
            return nil
        }
        skip()
        guard case .symbol("=") = currentToken else {
            print("Expected '=' after identifier; got \(currentToken)")
            return nil
        }
        skip()
        let expr = parseExpression()
        var variables:[JSVariable] = [JSVariable(name: name, value: expr)]
        while currentToken == .symbol(",") {
            skip()
            if let additionalVariables = parseVariableDeclarationsWithoutKeyword() {
                variables.append(contentsOf: additionalVariables)
            }
        }
        return variables
    }
}

// MARK: Function decl
extension JSParser {
    mutating func parseFunctionDeclaration() -> JSFunction? {
        guard case .keyword("function") = currentToken else {
            return nil
        }
        skip()

        guard case .identifier(let name) = currentToken else {
            print("Expected function name; got \(currentToken)")
            return nil
        }
        skip()

        guard case .symbol("(") = currentToken else {
            print("Expected '(' after function name; got \(currentToken)")
            return nil
        }
        skip()

        var parameters:[String] = []
        while case .identifier(let param) = currentToken {
            parameters.append(param)
            skip()
            if case .symbol(",") = currentToken {
                skip()
            } else {
                break
            }
        }

        guard case .symbol(")") = currentToken else {
            print("Expected ')' after parameters; got \(currentToken)")
            return nil
        }
        skip()

        guard case .symbol("{") = currentToken else {
            print("Expected '{' to start function body; got \(currentToken)")
            return nil
        }
        skip()

        var body:[JSFunction.BodyElement] = []
        while currentToken != .symbol("}") {
            if let s = parseStatement() {
                body.append(.statement(s))
            } else {
                let expr = parseExpression()
                body.append(.expression(expr))
                skip()
            }
        }
        guard case .symbol("}") = currentToken else {
            print("Expected '}' to close function body; got \(currentToken)")
            return nil
        }
        skip()
        return JSFunction(name: name, parameters: parameters, body: body)
    }
}

// MARK: If
extension JSParser {
    mutating func parseIfStatement() -> IfStatement? {
        guard case .keyword("if") = currentToken else {
            return nil
        }
        skip()

        guard case .symbol("(") = currentToken else {
            print("Expected '(' after 'if'; got \(currentToken)")
            return nil
        }
        skip()

        let condition = parseExpression()
        guard case .symbol(")") = currentToken else {
            print("Expected ')' after condition; got \(currentToken)")
            return nil
        }
        skip()

        guard case .symbol("{") = currentToken else {
            print("Expected '{' to start 'if' block; got \(currentToken)")
            return nil
        }
        skip()

        var block:[JSStatement] = []
        while currentToken != .symbol("}") {
            if let s = parseStatement() {
                block.append(s)
            } else {
                print("Invalid statement in 'if' block")
                break
            }
        }

        guard case .symbol("}") = currentToken else {
            print("Expected '}' to close 'if' block; got \(currentToken)")
            return nil
        }
        skip()

        var elseBranch:[JSStatement]? = nil
        if case .keyword("else") = currentToken {
            skip()
            guard case .symbol("{") = currentToken else {
                print("Expected '{' to start 'else' block; got \(currentToken)")
                return nil
            }
            skip()
            var elses:[JSStatement] = []
            while currentToken != .symbol("}") {
                if let stmt = parseStatement() {
                    elses.append(stmt)
                } else {
                    print("Invalid statement in 'else' block")
                    break
                }
            }
            guard case .symbol("}") = currentToken else {
                print("Expected '}' to close 'else' block; got \(currentToken)")
                return nil
            }
            skip()
            elseBranch = elses
        }
        return IfStatement(condition: condition, thenBranch: block, elseBranch: elseBranch)
    }
}

// MARK: Object literal
extension JSParser {
    private mutating func parseObjectLiteral() -> JSExpr {
        skip() // consume '{'
        var pairs:[String:JSExpr] = [:]
        while currentToken != .symbol("}") {
            guard case .identifier(let key) = currentToken else {
                fatalError("Expected identifier for object key; got \(currentToken)")
            }
            skip()

            guard case .symbol(":") = currentToken else {
                fatalError("Expected ':' after key; got \(currentToken)")
            }
            skip()

            pairs[key] = parseExpression()
            if case .symbol(",") = currentToken {
                skip()
            } else {
                break
            }
        }

        guard case .symbol("}") = currentToken else {
            fatalError("Expected '}' to close object literal; got \(currentToken)")
        }
        skip()
        return .objectLiteral(pairs)
    }
}

// MARK: Array literal
extension JSParser {
    private mutating func parseArrayLiteral() -> JSExpr {
        skip() // consume '['
        var elements:[JSExpr] = []
        while currentToken != .symbol("]") {
            elements.append(parseExpression())
            if case .symbol(",") = currentToken {
                skip()
            } else {
                break
            }
        }
        guard case .symbol("]") = currentToken else {
            fatalError("Expected ']' to close array; got \(currentToken)")
        }
        skip()
        return .arrayLiteral(elements)
    }
}

// MARK: Unary op
extension JSParser {
    private mutating func parseUnary() -> JSExpr {
        if case .symbol(let op) = currentToken, JSLexer.unaryTokens.contains(op) {
            skip()
            return .unaryOp(op, parseUnary())
        }
        return parsePrimary()
    }
}