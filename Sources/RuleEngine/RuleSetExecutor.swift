//
//  RuleSetExecutor.swift
//  RuleEngine
//
//  Created by Kanj on 09/06/25.
//
import Foundation

public protocol RuleSetExecutor {
    associatedtype Output: Codable
    func executeFirstMatch(clientId: String, ruleSet: RuleSet, consumerContext: ConsumerContext, timeZoneProvider: TimeZoneProvider) throws -> Output?
}

class RuleSetExecutorImpl<Output: Codable>: RuleSetExecutor {

    func executeFirstMatch(clientId: String, ruleSet: RuleSet, consumerContext: ConsumerContext, timeZoneProvider: TimeZoneProvider) throws -> Output? {
        try executeFirstMatchInternal(clientId: clientId, ruleSet: ruleSet, consumerContext: consumerContext, timeZoneProvider: timeZoneProvider)
    }

    private func executeFirstMatchInternal(clientId: String, ruleSet: RuleSet, ruleSetConfig: RuleSetConfig? = nil, consumerContext: ConsumerContext, timeZoneProvider: TimeZoneProvider) throws -> Output? {

        let executionLog = RuleEngineExecutionLog(clientId: clientId, ruleSetConfig: ruleSetConfig, consumerContext: consumerContext)

        let activeRules = ruleSet.rules.filter { $0.status != .inactive }
        for ruleInfo in activeRules {
            guard let rule = ruleInfo.rule else {
                continue
            }

            let ruleExecutor = RuleExcecutorImpl<Output>(timeZoneProvider: timeZoneProvider)
            let ruleOutput = try ruleExecutor.execute(clientId: clientId, rule: rule, consumerContext: consumerContext)
            if let executionDetails = ruleOutput.executionDetails {
                executionLog.executionDetails.ruleExecutions.append(executionDetails)
            }

            if ruleOutput.actionsExecutionInfo?.forceStopRuleSetExecution == true {
                captureSuccess(in: executionLog)
                return ruleOutput.evaluatedData
            }

            if ruleOutput.isSuccess == true {
                captureSuccess(in: executionLog)
                return ruleOutput.evaluatedData
            }
        }

        guard let defaultOutput = ruleSet.defaultOutput else {
            captureSuccess(in: executionLog)
            return nil
        }

        let ruleExecutor = RuleExcecutorImpl<Output>(timeZoneProvider: timeZoneProvider)
        let defaultOutputRule = Rule.with(successOutput: defaultOutput)
        let ruleOutput = try ruleExecutor.execute(clientId: clientId, rule: defaultOutputRule, consumerContext: consumerContext)
        captureSuccess(in: executionLog)
        return ruleOutput.evaluatedData
    }

    private func captureSuccess(in executionLog: RuleEngineExecutionLog) {
        executionLog.endTimestamp = Date()
        executionLog.executionStatus = .success
    }

    private func captureFailure(in executionLog: RuleEngineExecutionLog, error: Error?) {
        executionLog.endTimestamp = Date()
        executionLog.errorMessage = error?.localizedDescription
        executionLog.executionStatus = .failure
    }
}
