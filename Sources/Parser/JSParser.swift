import Lexer

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

    var lexer:JSLexer
    var currentToken:JSToken
    
    public init(input: String) {
        self.lexer = JSLexer(input: input)
        self.currentToken = lexer.nextToken()
    }

    mutating func skip() {
        currentToken = lexer.nextToken()
    }
}

// MARK: Expression
extension JSParser {
    mutating func parseExpression(precedence minPrec: Int = 0) -> JSExpr {
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
        case .string(_, let value):
            skip()
            return .string(value)
        case .keyword(let w) where w == "true" || w == "false":
            skip()
            return .boolean(w == "true")
        case .keyword("undefined"):
            skip()
            return .undefined
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

// MARK: Unary op
extension JSParser {
    mutating func parseUnary() -> JSExpr {
        if case .symbol(let op) = currentToken, JSLexer.unaryTokens.contains(op) {
            skip()
            return .unaryOp(op, parseUnary())
        }
        return parsePrimary()
    }
}