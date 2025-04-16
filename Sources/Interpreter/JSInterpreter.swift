import Parser

class Environment {
    var variables: [String: JSExpr] = [:]

    func get(_ name: String) -> JSExpr? {
        return variables[name]
    }

    func set(_ name: String, value: JSExpr) {
        variables[name] = value
    }
}

struct Interpreter {
    var environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func evaluate(_ expr: JSExpr) -> JSExpr {
        switch expr {
        case .unknown:
            return .unknown
        case .number(let value):
            return .number(value)
        case .string(let value):
            return .string(value)
        case .boolean(let value):
            return .boolean(value)
        case .identifier(let name):
            if let value = environment.get(name) {
                return value
            } else {
                fatalError("Undefined variable: \(name)")
            }
        case .binaryOp(let op, let left, let right):
            return evaluateBinaryOp(op, left: left, right: right)
        case .unaryOp(let op, let expr):
            return evaluateUnaryOp(op, expr: expr)
        case .assignment(let variable, let value):
            return evaluateAssignment(variable: variable, value: value)
        case .compoundAssignment(let op, let variable, let value):
            return evaluateCompoundAssignment(op, variable: variable, value: value)
        case .propertyAccess(let object, let property):
            return evaluatePropertyAccess(object: object, property: property)
        case .call(let callee, let arguments):
            return evaluateCall(callee: callee, arguments: arguments)
        case .objectLiteral(let properties):
            return .objectLiteral(properties)
        case .arrayLiteral(let elements):
            return .arrayLiteral(elements)
        }
    }

    private func evaluateBinaryOp(_ op: String, left: JSExpr, right: JSExpr) -> JSExpr {
        let leftValue = evaluate(left)
        let rightValue = evaluate(right)
        switch op {
        case "+":
            if case .number(let l) = leftValue, case .number(let r) = rightValue {
                return .number(l + r)
            }
        case "-":
            if case .number(let l) = leftValue, case .number(let r) = rightValue {
                return .number(l - r)
            }
        case "*":
            if case .number(let l) = leftValue, case .number(let r) = rightValue {
                return .number(l * r)
            }
        case "/":
            if case .number(let l) = leftValue, case .number(let r) = rightValue {
                return .number(l / r)
            }
        default:
            fatalError("Unknown operator: \(op)")
        }
        return .number(0) // default case
    }

    private func evaluateUnaryOp(_ op: String, expr: JSExpr) -> JSExpr {
        let value = evaluate(expr)
        switch op {
        case "!":
            if case .boolean(let b) = value {
                return .boolean(!b)
            }
        case "-":
            if case .number(let n) = value {
                return .number(-n)
            }
        default:
            fatalError("Unknown unary operator: \(op)")
        }
        return value
    }

    private func evaluateAssignment(variable: JSExpr, value: JSExpr) -> JSExpr {
        guard case .identifier(let varName) = variable else {
            fatalError("Left-hand side of assignment must be a variable")
        }
        let evaluatedValue = evaluate(value)
        environment.set(varName, value: evaluatedValue)
        return evaluatedValue
    }

    private func evaluateCompoundAssignment(_ op: String, variable: JSExpr, value: JSExpr) -> JSExpr {
        guard case .identifier(let varName) = variable else {
            fatalError("Left-hand side of compound assignment must be a variable")
        }
        
        let currentValue = environment.get(varName) ?? .number(0)
        let evaluatedValue = evaluate(value)
        var result:JSExpr = .number(0)
        switch op {
        case "+=":
            if case .number(let current) = currentValue, case .number(let val) = evaluatedValue {
                result = .number(current + val)
            }
        case "-=":
            if case .number(let current) = currentValue, case .number(let val) = evaluatedValue {
                result = .number(current - val)
            }
        case "*=":
            if case .number(let current) = currentValue, case .number(let val) = evaluatedValue {
                result = .number(current * val)
            }
        case "/=":
            if case .number(let current) = currentValue, case .number(let val) = evaluatedValue {
                result = .number(current / val)
            }
        default:
            fatalError("Unknown compound operator: \(op)")
        }
        environment.set(varName, value: result)
        return result
    }

    private func evaluatePropertyAccess(object: JSExpr, property: String) -> JSExpr {
        let obj = evaluate(object)
        switch obj {
        case .objectLiteral(let properties):
            if let value = properties[property] {
                return value
            } else {
                fatalError("Property \(property) not found in object")
            }
        default:
            fatalError("Attempt to access property of a non-object: \(obj)")
        }
    }

    private func evaluateCall(callee: JSExpr, arguments: [JSExpr]) -> JSExpr {
        fatalError("Function calls are not implemented yet")
    }
}
