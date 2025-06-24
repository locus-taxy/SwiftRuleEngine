public struct RuleSet: Codable {
    let rules: [RuleInfo]
    let defaultOutput: RuleOutput?
}

public struct RuleInfo: Codable {
    let priority: Int?
    let status: RuleStatus?
    let rule: Rule?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.priority = try container.decodeIfPresent(Int.self, forKey: .priority)
        self.status = try? container.decodeIfPresent(RuleStatus.self, forKey: .status)
        self.rule = try container.decodeIfPresent(Rule.self, forKey: .rule)
    }
}

public struct RuleOutput: Codable {
    let id: String?
    let data: OutputValue?
}

public enum RuleStatus: String, Codable {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
}

public struct Rule: Codable {
    let id: String?
    let name: String?
    let summary: String?
    let conditionSet: ConditionSet?
    let successOutput: RuleOutput?
    let failureOutput: RuleOutput?
}

extension Rule {
    static func with(successOutput: RuleOutput) -> Rule {
        Rule(
            id: nil,
            name: nil,
            summary: nil,
            conditionSet: ConditionSet(),
            successOutput: successOutput,
            failureOutput: nil
        )
    }
}

public struct ConditionSet: Codable {
    let joinOperator: JoinOperator?
    let conditions: [Condition]

    init() {
        self.joinOperator = nil
        self.conditions = []
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.joinOperator = try? container.decodeIfPresent(JoinOperator.self, forKey: .joinOperator)
        self.conditions = try container.decode([Condition].self, forKey: .conditions)
    }
}

public enum JoinOperator: String, Codable {
    case allOf = "ALL_OF"
    case anyOf = "ANY_OF"
}

public struct Condition: Codable {
    let id: String?
    let conditionType: ConditionType?
    let joinDetails: JoinConditionDetails?
    let filterDetails: FilterConditionDetails?
    let loopDetails: LoopConditionDetails?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.conditionType = try? container.decodeIfPresent(ConditionType.self, forKey: .conditionType)
        self.joinDetails = try container.decodeIfPresent(JoinConditionDetails.self, forKey: .joinDetails)
        self.filterDetails = try container.decodeIfPresent(FilterConditionDetails.self, forKey: .filterDetails)
        self.loopDetails = try container.decodeIfPresent(LoopConditionDetails.self, forKey: .loopDetails)
    }
}

public enum ConditionType: String, Codable {
    case join = "JOIN"
    case filter = "FILTER"
    case loop = "LOOP"
}

public struct JoinConditionDetails: Codable {
    let joinOperator: JoinOperator?
    let conditions: [Condition]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.joinOperator = try? container.decodeIfPresent(JoinOperator.self, forKey: .joinOperator)
        self.conditions = try container.decode([Condition].self, forKey: .conditions)
    }
}

public struct FilterConditionDetails: Codable {
    let `operator`: FilterOperator?
    let operands: [Value]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.operator = try? container.decodeIfPresent(FilterOperator.self, forKey: .operator)
        self.operands = try container.decode([Value].self, forKey: .operands)
    }
}

public struct LoopConditionDetails: Codable {
    let loopTarget: Value?
    let loopVariable: Value?
    let joinOperator: JoinOperator?
    let conditions: [Condition]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.loopTarget = try container.decodeIfPresent(Value.self, forKey: .loopTarget)
        self.loopVariable = try container.decodeIfPresent(Value.self, forKey: .loopVariable)
        self.joinOperator = try? container.decodeIfPresent(JoinOperator.self, forKey: .joinOperator)
        self.conditions = try container.decode([Condition].self, forKey: .conditions)
    }
}

public struct Value: Codable {
    let id: String?
    let type: ValueType?
    let value: String?

    init(value: String?) {
        self.id = nil
        self.type = nil
        self.value = value
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.type = try? container.decodeIfPresent(ValueType.self, forKey: .type)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
    }
}

public enum ValueType: String, Codable {
    case dynamic = "DYNAMIC"
    case `static` = "STATIC"
}

public struct OutputValue: Codable {
    let id: String?
    let type: OutputValueType?
    let value: OutputValueResult?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.type = try? container.decodeIfPresent(OutputValueType.self, forKey: .type)
        self.value = try container.decodeIfPresent(OutputValueResult.self, forKey: .value)
    }
}

public enum OutputValueType: String, Codable {
    case nested = "NESTED"
    case dynamic = "DYNAMIC"
    case `static` = "STATIC"
}

public struct OutputValueResult: Codable {
    let result: Value?
}
