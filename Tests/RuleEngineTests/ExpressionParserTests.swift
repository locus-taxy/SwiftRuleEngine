//
//  ExpressionParserTests.swift
//  RuleEngine
//
//  Created by Kanj on 17/06/25.
//
@testable import RuleEngine
import Testing

@Suite("Test expression parser")
struct ExpressionParserTests {

    @Test func basic() async throws {
        let expr1 = "SUM(object.property1, FLOOR(object.property2))"
        var parser = REExpressionParser(input: expr1)
        let tree1 = try? parser.parse()
        guard let tree = tree1, case let .functionCall(functionName, arguments) = tree else {
            Issue.record("Failed to parse expression 1")
            return
        }
        #expect(functionName == "SUM")
        #expect(arguments.count == 2)

        if case let .property(path) = arguments[0] {
            #expect(path == "object.property1")
        } else {
            Issue.record("Error in parsing")
        }

        if case let .functionCall(functionName, arguments) = arguments[1] {
            #expect(functionName == "FLOOR")
            #expect(arguments.count == 1)
            if case let .property(path) = arguments[0] {
                #expect(path == "object.property2")
            } else {
                Issue.record("Error in parsing")
            }
        } else {
            Issue.record("Error in parsing")
        }
    }
}
