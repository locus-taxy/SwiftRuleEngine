import Foundation

public struct RuleSetConfig {
    let clientId: String?
    let ruleSetId: String?
    let name: String?
    let description: String?
    let useCase: String?
    let product: String?
    let triggerInfo: RuleSetTriggerInfo?
    let uniqueKeys: [String: [String]]
    let searchKeys: [String: [String]]
    let ruleSetInfo: RuleSetInfo?
    let status: RuleSetConfigStatus?
    let externalDataSourcesConfig: RuleSetExternalDataSourcesConfig?
    let version: Int?
    let auditMetadata: AuditMetadata?
}

struct RuleSetTriggerInfo {
    let id: String?
    let parameterisedId: String?
    let parameters: [String: String]
}

struct RuleSetInfo {
    let ruleSet: RuleSet?
}

enum RuleSetConfigStatus: String {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
}

struct RuleSetExternalDataSourcesConfig {
    let dataSources: [RuleSetExternalDataSourceConfig]
}

struct RuleSetExternalDataSourceConfig {
    let id: String?
    let name: String?
    let config: [String: Any]
}

struct AuditMetadata {
    let createdBy: Actor?
    let createdOn: Date?
    let createdOnDate: String?
    let updatedBy: Actor?
    let updatedOn: Date?
    let updatedOnDate: String?
}

struct Actor {
    let id: String?
}
