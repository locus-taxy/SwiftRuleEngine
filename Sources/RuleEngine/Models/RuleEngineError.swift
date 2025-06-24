//
//  RuleEngineError.swift
//  RuleEngine
//
//  Created by Kanj on 11/06/25.
//
import Foundation

enum RuleEngineError: Error {
    case generic(message: String)
}

extension RuleEngineError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .generic(message):
            message
        }
    }
}
