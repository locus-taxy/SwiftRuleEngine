struct EvaluateValueResult {
    let value: Value?
    let evaluatedValue: Any?
}

enum ExpressionEvaluator {

    private static let rootKey = "input"

    static func evaluateValue(value: Value?, consumerContext: ConsumerContext?) throws -> EvaluateValueResult? {

        guard let expressionString = value?.value else {
            return nil
        }

        guard expressionString.hasPrefix("${"), expressionString.hasSuffix("}") else {
            // Return the string itself as value, don't evaluate
            return EvaluateValueResult(value: value, evaluatedValue: expressionString)
        }

        let startIndex = expressionString.index(expressionString.startIndex, offsetBy: 2)
        let endIndex = expressionString.index(before: expressionString.endIndex)
        let expression = String(expressionString[startIndex ..< endIndex])

        // Try to parse function call first
        var expressionParser = REExpressionParser(input: expression)
        if let expressionTree = try? expressionParser.parse(),
           case let .functionCall(functionName, arguments) = expressionTree
        {
            let result = try executeFunction(name: functionName, arguments: arguments)
            return EvaluateValueResult(value: value, evaluatedValue: result)
        }

        let propertyObject = try readProperty(expression: expression, consumerContext: consumerContext)
        return EvaluateValueResult(value: value, evaluatedValue: propertyObject)
    }

    private static func executeFunction(name _: String, arguments _: [REExpression]) throws -> Any? {
        // TODO: Kanj - implement
        nil
    }

    private static func readProperty(expression: String, consumerContext: ConsumerContext?) throws -> Any? {
        let keys = expression.split(separator: ".").map(String.init)
        if keys.isEmpty {
            return nil
        }

        if keys[0] != rootKey {
            throw RuleEngineError.generic(message: "Invalid exprssion syntax, only input can be accessed")
        }

        guard let input = consumerContext?.inputParams else {
            if keys.count == 1 {
                return nil
            }

            throw RuleEngineError.generic(message: "Input is nil")
        }

        var keyIndex = 1
        var object: Any? = input

        while keyIndex < keys.count {
            guard let currentObj = object else { break }
            object = try getObject(withKey: keys[keyIndex], in: currentObj)
            keyIndex += 1
        }

        if keyIndex == keys.count {
            return object
        }

        throw RuleEngineError.generic(message: "Can't access \(keys[keyIndex]) in nil")
    }

    private static func getObject(withKey key: String, in object: Any) throws -> Any? {

        if let (arrayName, index) = keyToAccessArray(key: key) {
            if let array = getArray(withName: arrayName, in: object) {
                if index >= 0, index < array.count {
                    return array[index]
                }

                throw RuleEngineError.generic(message: "Invalid index \(index) in \(arrayName)")
            }

            throw RuleEngineError.generic(message: "Can't access \(key)")
        }

        if let map = object as? [String: Any] {
            return map[key]
        }

        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            print("Label: \(String(describing: child.label)), value: \(child.value)")
        }
        if let child = mirror.children.first(where: { $0.label == key }) {
            return unwrapOptional(child.value)
        }

        return nil
    }

    private static func unwrapOptional(_ any: Any) -> Any? {
        let mirror = Mirror(reflecting: any)
        if mirror.displayStyle != .optional {
            return any
        }
        if let child = mirror.children.first {
            return unwrapOptional(child.value)
        }
        return nil
    }

    private static func getArray(withName name: String, in object: Any) -> [Any]? {
        let mirror = Mirror(reflecting: object)
        guard let child = mirror.children.first(where: { $0.label == name }) else {
            return nil
        }
        return child.value as? [Any]
    }

    private static func keyToAccessArray(key: String) -> (key: String, index: Int)? {
        guard let openBracket = key.firstIndex(of: "["),
              let closeBracket = key.firstIndex(of: "]"),
              openBracket < closeBracket
        else {
            return nil
        }

        let arrayName = String(key[..<openBracket])
        let indexString = String(key[key.index(after: openBracket) ..< closeBracket])

        if let index = Int(indexString) {
            return (arrayName, index)
        } else {
            return nil
        }
    }
}
