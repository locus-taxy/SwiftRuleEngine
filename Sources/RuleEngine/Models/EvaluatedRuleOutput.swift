//
//  EvaluatedRuleOutput.swift
//  RuleEngine
//
//  Created by Kanj on 11/06/25.
//
import Foundation

public struct EvaluatedRuleOutput<T: Codable> {
    let isSuccess: Bool?
    let rule: Rule?
    let matchingOutput: RuleOutput?
    let evaluatedData: T?
    let actionsExecutionInfo: ActionsExecutionInfo?
    let executionDetails: RuleExecutionDetails?
}

public struct ActionsExecutionInfo {
    let actionExecutionInfos: [ActionExecutionInfo]
    let forceStopRuleSetExecution: Bool?
    let latestConsumerContext: ConsumerContext?
    let latestAvailableOutput: ActionOutput?
    let latestExecutionInfo: ActionExecutionInfo?
}

public class RuleExecutionDetails {
    let startTimestamp: Date?

    var id: String?
    var conditionExecutions = [ConditionExecutionDetails]()
    var outputExecution: OutputExecutionDetails?
    var endTimestamp: Date?

    init() {
        self.startTimestamp = Date()
    }
}

public struct ConditionExecutionDetails {
    let id: String?
    let loopVariables: [String: Any?]?
    let evaluatedValues: [Any]
    let result: Bool?
}

public class OutputExecutionDetails {
    var actionExecutions = [ActionExecutionDetails]()
    var result: Bool?
    var evaluatedOutput: Any?
}

public struct ActionExecutionDetails {
    let id: String?
    let executionId: String?
    let function: String?
    let evaluatedInput: Any?
    let isDryRun: Bool?
    let executionStatus: ActionExecutionStatus?
    let reasonCode: ActionExecutionReasonCode?
}

public enum ActionExecutionReasonCode: String {
    case actionNotAvailable = "ACTION_NOT_AVAILABLE"
    case unknownFailure = "UNKNOWN_FAILURE"
}

public enum ActionExecutionStatus: String {
    case success = "SUCCESS"
    case failure = "FAILURE"
    case dryRun = "DRY_RUN"
}

public class RuleSetExecutionDetails {
    var ruleExecutions = [RuleExecutionDetails]()
}

public struct RuleSetAllMatchOutput<Output: Codable> {
    let output: [Output]
    let ruleOutputs: [EvaluatedRuleOutput<Output>]
    let latestRuleOutput: EvaluatedRuleOutput<Output>?
    let latestContext: ConsumerContext?
}

public struct RuleSetFirstMatchOutput<Output> {
    let output: Output?
}

public struct ActionExecutionInfo {}

public struct ActionOutput {}
