//
//  Operations.swift
//  RuleEngine
//
//  Created by Kanj on 13/06/25.
//
import Foundation

enum Operations {

    static func isNull(operand: Any?) -> Bool {
        operand == nil
    }

    static func isTrue(operand: Any?) -> Bool {
        guard let operand, let boolOperand = operand as? Bool, boolOperand else { return false }
        return true
    }

    static func isFalse(operand: Any?) -> Bool {
        guard let operand, let boolOperand = operand as? Bool, !boolOperand else { return false }
        return true
    }

    static func isEqual(operand1: Any?, operand2: Any?) -> Bool {
        switch (operand1, operand2) {
        case (nil, nil):
            true
        case let (lhs?, rhs?):
            switch (lhs, rhs) {
            case let (l as Int, r as Int): l == r
            case let (l as Double, r as Double): l == r
            case let (l as Float, r as Float): l == r
            case let (l as String, r as String): l == r
            case let (l as Bool, r as Bool): l == r
            case let (l as Date, r as Date): l == r
            default:
                compareEnumAndString(lhs: lhs, rhs: rhs)
            }
        default:
            false
        }
    }

    private static func compareEnumAndString(lhs: Any?, rhs: Any?) -> Bool {
        guard let str1 = asStringOrEnumRawString(lhs),
              let str2 = asStringOrEnumRawString(rhs)
        else {
            return false
        }

        return str1 == str2
    }

    private static func asStringOrEnumRawString(_ object: Any?) -> String? {
        guard let object else { return nil }

        if let string = object as? String {
            return string
        }

        let mirror = Mirror(reflecting: object)
        guard mirror.displayStyle == .enum else {
            return nil
        }

        if let rawRepresentable = object as? any RawRepresentable {
            return rawRepresentable.rawValue as? String
        }

        return nil
    }

    static func isGreaterThan(operand1: Any?, operand2: Any?) throws -> Bool {
        guard let lhs = operand1, let rhs = operand2 else {
            throw RuleEngineError.generic(message: "Both operands must be non-nil")
        }

        switch (lhs, rhs) {
        case let (l as Int, r as Int):
            return l > r
        case let (l as Double, r as Double):
            return l > r
        case let (l as Float, r as Float):
            return l > r
        case let (l as Date, r as Date):
            return l > r
        default:
            if type(of: lhs) != type(of: rhs) {
                throw RuleEngineError.generic(message: "Both operands must have the same type")
            } else {
                throw RuleEngineError.generic(message: "Both operands must be Int, Double, Float or Date")
            }
        }
    }

    static func isLessThan(operand1: Any?, operand2: Any?) throws -> Bool {
        guard let lhs = operand1, let rhs = operand2 else {
            throw RuleEngineError.generic(message: "Both operands must be non-nil")
        }

        switch (lhs, rhs) {
        case let (l as Int, r as Int):
            return l < r
        case let (l as Double, r as Double):
            return l < r
        case let (l as Float, r as Float):
            return l < r
        case let (l as Date, r as Date):
            return l < r
        default:
            if type(of: lhs) != type(of: rhs) {
                throw RuleEngineError.generic(message: "Both operands must have the same type")
            } else {
                throw RuleEngineError.generic(message: "Both operands must be Int, Double, Float or Date")
            }
        }
    }

    static func isIn(operand1: Any?, operand2: Any?) throws -> Bool {
        guard let lhs = operand1 else {
            throw RuleEngineError.generic(message: "First operand must not be nil")
        }

        let typeMismatchError = RuleEngineError.generic(message: "Second operand has an incompatible type")
        switch lhs {
        case let intVal as Int:
            guard let arr = operand2 as? [Int] else { throw typeMismatchError }
            return arr.contains(intVal)
        case let floatVal as Float:
            guard let arr = operand2 as? [Float] else { throw typeMismatchError }
            return arr.contains(floatVal)
        case let doubleVal as Double:
            guard let arr = operand2 as? [Double] else { throw typeMismatchError }
            return arr.contains(doubleVal)
        case let strVal as String:
            guard let arr = operand2 as? [String] else { throw typeMismatchError }
            return arr.contains(strVal)
        case let boolVal as Bool:
            guard let arr = operand2 as? [Bool] else { throw typeMismatchError }
            return arr.contains(boolVal)
        case let dateVal as Date:
            guard let arr = operand2 as? [Date] else { throw typeMismatchError }
            return arr.contains(dateVal)
        default:
            throw RuleEngineError.generic(message: "First operand must be Int, Float, Double, String, Bool or Date")
        }
    }
}
