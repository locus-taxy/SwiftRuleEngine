//
//  RuleEngineExecutionLog.swift
//  RuleEngine
//
//  Created by Kanj on 11/06/25.
//
import Foundation

enum RuleEngineExecutionLogStatus: String {
    case success = "SUCCESS"
    case failure = "FAILURE"
}

class RuleEngineExecutionLog {

    private let clientId: String
    private let executionId: String
    private let ruleSetVersion: Int?
    private let ruleSetId: String?
    private let startTimestamp: Date
    private let primaryEntityId: String?
    private let secondaryEntityIds: [String]
    private let triggerId: String?
    private let useCase: String?

    let executionDetails: RuleSetExecutionDetails

    var endTimestamp: Date?
    var executionStatus: RuleEngineExecutionLogStatus?
    var errorMessage: String?

    init(clientId: String, ruleSetConfig: RuleSetConfig?, consumerContext _: ConsumerContext) {
        self.clientId = clientId
        self.executionId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        self.ruleSetVersion = ruleSetConfig?.version
        self.ruleSetId = ruleSetConfig?.ruleSetId
        self.startTimestamp = Date()
        // TODO: What the hell is EntityReferences?
        self.primaryEntityId = nil
        self.secondaryEntityIds = []
        self.triggerId = ruleSetConfig?.triggerInfo?.id
        self.useCase = ruleSetConfig?.useCase

        self.executionDetails = RuleSetExecutionDetails()
    }
}
