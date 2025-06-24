//
//  OperationsTests.swift
//  RuleEngine
//
//  Created by Kanj on 13/06/25.
//
import Foundation
@testable import RuleEngine
import Testing

@Suite("Test Operations")
struct OperationsTests {

    @Test func testIsNull() async throws {
        let ops: [Any?] = [
            nil, false, true, "abc", 100, Date(), Elephant(name: "xyz", height: 3.1, weight: 500.8),
        ]

        for (i, op) in ops.enumerated() {
            let result = Operations.isNull(operand: op)
            if i == 0 {
                #expect(result, "Only the first is nil")
            } else {
                #expect(!result, "everything else is non nil")
            }
        }
    }

    @Test func testIsTrue() async throws {
        let ops: [Any?] = [
            true, false, nil, "abc", 100, Date(), Elephant(name: "xyz", height: 3.1, weight: 500.8),
        ]

        for (i, op) in ops.enumerated() {
            let result = Operations.isTrue(operand: op)
            if i == 0 {
                #expect(result, "true is true")
            } else {
                #expect(!result, "everything else is false")
            }
        }
    }

    @Test func testIsFalse() async throws {
        let ops: [Any?] = [
            false, true, nil, "abc", 100, Date(), Elephant(name: "xyz", height: 3.1, weight: 500.8),
        ]

        for (i, op) in ops.enumerated() {
            let result = Operations.isFalse(operand: op)
            if i == 0 {
                #expect(result, "false is false")
            } else {
                #expect(!result, "everything else is true :-)")
            }
        }
    }

    @Test func testIsEqual() async throws {

        let date1 = Date(timeIntervalSince1970: 1_750_237_342)
        let date2 = Date(timeIntervalSince1970: 1_750_237_342)
        let date3 = Date(timeIntervalSince1970: 1_750_237_343)

        let blackAnt1 = Ant.black
        let blackAnt2 = Ant.black
        let redAnt = Ant.red

        let ops: [(Any?, Any?)] = [
            (nil, nil),
            (100, 100),
            (100.5, 100.5),
            ("abc", "abc"),
            (true, true),
            (false, false),
            (date1, date2),
            (blackAnt1, "BLACK"),
            (blackAnt1, blackAnt2),
            ("RED", redAnt),
            (nil, "xyz"),
            (nil, 1),
            (100, "abc"),
            (100, 200),
            ("abc", "xyz"),
            (true, 100),
            (2, false),
            (true, false),
            (date1, date3),
            (date1, 1_750_237_342),
            (date1, "abc"),
            (date1, nil),
            (blackAnt1, redAnt),
            (blackAnt1, "RED"),
            (blackAnt1, 1),
        ]

        for (i, (op1, op2)) in ops.enumerated() {
            let result = Operations.isEqual(operand1: op1, operand2: op2)
            if i < 10 {
                #expect(result, "First 10 are true")
            } else {
                #expect(!result, "Remaining are false")
            }
        }
    }

    @Test func testIsGreaterThan() async throws {

        let date1 = Date(timeIntervalSince1970: 1_750_237_342)
        let date2 = Date(timeIntervalSince1970: 1_750_237_342)
        let date3 = Date(timeIntervalSince1970: 1_750_237_343)

        let ops: [(Any?, Any?)] = [
            (2, 1),
            (2.7, 1.6),
            (2, -2),
            (-3, -5),
            (-9.8, -11.7),
            (date3, date1),
            (1, 2),
            (1, 1),
            (date1, date2),
            (1.6, 2.7),
            (2.7, 2.7),
            (-2, 1),
            (-5, -3),
            (-11.7, -9.8),
            (-13.13, -13.13),
            (date2, date3),
        ]

        for (i, (op1, op2)) in ops.enumerated() {
            let result = try Operations.isGreaterThan(operand1: op1, operand2: op2)
            if i < 6 {
                #expect(result, "First 6 are true")
            } else {
                #expect(!result, "Remaining are false")
            }
        }

        let opsWithError: [(Any?, Any?)] = [
            (nil, nil),
            (1, nil),
            (nil, 3.1),
            (1, 3.2),
            (4.3, 2),
            (2, "abc"),
            ("xyz", "abc"),
            ("xyz", 6.7),
            (date1, nil),
            (date3, 1_750_237_342),
            (date2, "abc"),
            (date1, 4),
        ]

        for (op1, op2) in opsWithError {
            #expect(throws: RuleEngineError.self) {
                try Operations.isGreaterThan(operand1: op1, operand2: op2)
            }
        }
    }

    @Test func testIsLessThan() async throws {

        let date1 = Date(timeIntervalSince1970: 1_750_237_342)
        let date2 = Date(timeIntervalSince1970: 1_750_237_342)
        let date3 = Date(timeIntervalSince1970: 1_750_237_343)

        let ops: [(Any?, Any?)] = [
            (1, 2),
            (1.6, 2.7),
            (-2, 2),
            (-5, -3),
            (-11.7, -9.8),
            (date1, date3),
            (2, 1),
            (1, 1),
            (date1, date2),
            (date3, date2),
            (2.7, 1.6),
            (2.7, 2.7),
            (1, -2),
            (-3, -5),
            (-9.8, -11.7),
            (-13.13, -13.13),
        ]

        for (i, (op1, op2)) in ops.enumerated() {
            let result = try Operations.isLessThan(operand1: op1, operand2: op2)
            if i < 6 {
                #expect(result, "First 6 are true")
            } else {
                #expect(!result, "Remaining are false")
            }
        }

        let opsWithError: [(Any?, Any?)] = [
            (nil, nil),
            (1, nil),
            (nil, 3.1),
            (3.2, 1),
            (2, 4.3),
            (2, "abc"),
            ("xyz", "abc"),
            ("xyz", 6.7),
            (date1, nil),
            (date2, 1_750_237_343),
            (date2, "abc"),
            (date1, 4.5),
        ]

        for (op1, op2) in opsWithError {
            #expect(throws: RuleEngineError.self) {
                try Operations.isLessThan(operand1: op1, operand2: op2)
            }
        }
    }

    @Test func testIsIn() async throws {

        let date1 = Date(timeIntervalSince1970: 1_750_237_342)
        let date2 = Date(timeIntervalSince1970: 1_750_237_342)
        let date3 = Date(timeIntervalSince1970: 1_750_237_343)

        let ops: [(Any?, [Any?]?)] = [
            (1, [2, 3, 1, 4, 10]),
            (3.14, [2.5, 5.61, 3.14]),
            (true, [false, true, false, true]),
            (false, [false, true, false, true]),
            ("abc", ["xyz", "432", "abc", ")_("]),
            (date1, [date2, date3, Date()]),
            (5, [2, 3, 1, 4, 10]),
            (5, []),
            (3.1428, [2.5, 5.61, 3.14]),
            (3.1428, []),
            (true, [false, false]),
            (false, [true, true]),
            (true, []),
            ("hello", ["xyz", "432", "abc", ")_("]),
            ("hello", []),
            (date1, [date3, Date()]),
            (date1, []),
        ]

        for (i, (op1, op2)) in ops.enumerated() {
            let result = try Operations.isIn(operand1: op1, operand2: op2)
            if i < 6 {
                #expect(result, "First 6 are true")
            } else {
                #expect(!result, "Remaining are false")
            }
        }

        let opsWithError: [(Any?, [Any?]?)] = [
            (1, [2.5, 3, 1, 4, 10.9]),
            (3.14, [2, 5, 3]),
            (true, [false, true, "false", true]),
            (false, nil),
            ("abc", [19, 432, "abc", ")_("]),
            ("abc", nil),
            (nil, nil),
            (nil, [2.5, 5.61, 3.14]),
            ("true", [false, false]),
            (99, [true, true]),
            (100, ["xyz", "432", "abc", ")_("]),
            (date1, [1, 3, 5]),
            (date1, nil),
            (date1, [false, true, false]),
        ]

        for (op1, op2) in opsWithError {
            #expect(throws: RuleEngineError.self) {
                try Operations.isIn(operand1: op1, operand2: op2)
            }
        }
    }
}
