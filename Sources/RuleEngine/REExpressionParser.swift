enum REExpression: CustomStringConvertible {
    case property(path: String)
    case functionCall(functionName: String, arguments: [REExpression])

    var description: String {
        switch self {
        case let .property(path):
            path
        case let .functionCall(name, args):
            "\(name)(\(args.map(\.description).joined(separator: ", ")))"
        }
    }
}

struct REExpressionParser {
    private let input: String
    private var index: String.Index

    init(input: String) {
        self.input = input
        self.index = input.startIndex
    }

    mutating func parse() throws -> REExpression {
        skipWhitespace()
        let expr = try parseExpression()
        skipWhitespace()
        if index != input.endIndex {
            throw parseError("Unexpected trailing characters")
        }
        return expr
    }

    private mutating func parseExpression() throws -> REExpression {
        let identifier = try parseIdentifier()

        skipWhitespace()

        if match("(") {
            // Function call
            let args = try parseArguments()
            return .functionCall(functionName: identifier, arguments: args)
        } else {
            // Property (possibly dotted path)
            var path = identifier
            while match(".") {
                let part = try parseIdentifier()
                path += "." + part
            }
            return .property(path: path)
        }
    }

    private mutating func parseArguments() throws -> [REExpression] {
        var args: [REExpression] = []

        skipWhitespace()
        if match(")") {
            return args // no arguments
        }

        while true {
            skipWhitespace()
            let arg = try parseExpression()
            args.append(arg)

            skipWhitespace()
            if match(")") {
                break
            } else if match(",") {
                continue
            } else {
                throw parseError("Expected ',' or ')'")
            }
        }

        return args
    }

    private mutating func parseIdentifier() throws -> String {
        let start = index
        guard index < input.endIndex, isIdentifierChar(input[index]) else {
            throw parseError("Expected identifier")
        }

        while index < input.endIndex, isIdentifierChar(input[index]) {
            index = input.index(after: index)
        }

        return String(input[start ..< index])
    }

    private func isIdentifierChar(_ char: Character) -> Bool {
        char.isLetter || char.isNumber || char == "_" // allow alphanumeric and underscores
    }

    private mutating func skipWhitespace() {
        while index < input.endIndex, input[index].isWhitespace {
            index = input.index(after: index)
        }
    }

    private mutating func match(_ expected: Character) -> Bool {
        guard index < input.endIndex, input[index] == expected else {
            return false
        }
        index = input.index(after: index)
        return true
    }

    private func parseError(_ message: String) -> Error {
        RuleEngineError.generic(message: message)
    }
}
