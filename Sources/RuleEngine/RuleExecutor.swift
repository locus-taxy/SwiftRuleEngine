//
//  Untitled.swift
//  RuleEngine
//
//  Created by Kanj on 11/06/25.
//
import Foundation

public protocol RuleExecutor {
    associatedtype Output: Codable
    func execute(clientId: String, rule: Rule, consumerContext: ConsumerContext) throws -> EvaluatedRuleOutput<Output>
}

class RuleExcecutorImpl<Output: Codable>: RuleExecutor {

    private let timeZoneProvider: TimeZoneProvider
    private let ruleExecutionDetails = RuleExecutionDetails()

    init(timeZoneProvider: TimeZoneProvider) {
        self.timeZoneProvider = timeZoneProvider
    }

    func execute(clientId: String, rule: Rule, consumerContext: any ConsumerContext) throws -> EvaluatedRuleOutput<Output> {

        ruleExecutionDetails.id = rule.id

        let context = WrappedConsumerContext(consumerContext: consumerContext)
        let conditionsResult = try evaluateConditions(conditions: rule.conditionSet?.conditions ?? [], joinOperator: rule.conditionSet?.joinOperator, consumerContext: context)

        if conditionsResult.result == false {
            print("execute rule result is false")
            return try evaluateOutputInternal(clientId: clientId, rule: rule, conditionsResult: conditionsResult, output: rule.failureOutput, consumerContext: context, result: false)
        }

        print("execute rule result is not false")
        return try evaluateOutputInternal(clientId: clientId, rule: rule, conditionsResult: conditionsResult, output: rule.successOutput, consumerContext: context, result: true)
    }

    private func evaluateOutputInternal<T: Codable>(clientId _: String, rule: Rule, conditionsResult: EvaluateConditionsResult?, output: RuleOutput?, consumerContext: ConsumerContext, result: Bool) throws -> EvaluatedRuleOutput<T> {

        print("evaluateOutputInternal: \(REUtils.toJson(output))")

        guard let output, let outputData = output.data else {
            ruleExecutionDetails.endTimestamp = Date()
            return EvaluatedRuleOutput(isSuccess: conditionsResult?.result, rule: rule, matchingOutput: nil, evaluatedData: nil, actionsExecutionInfo: nil, executionDetails: ruleExecutionDetails)
        }

        let evaluatedOutput: T? = try evaluateOutputValue(value: outputData, consumerContext: consumerContext)
        let outputExecutionDetails = ruleExecutionDetails.outputExecution ?? OutputExecutionDetails()
        outputExecutionDetails.result = result
        outputExecutionDetails.evaluatedOutput = evaluatedOutput
        ruleExecutionDetails.outputExecution = outputExecutionDetails
        ruleExecutionDetails.endTimestamp = Date()
        return EvaluatedRuleOutput(isSuccess: conditionsResult?.result, rule: rule, matchingOutput: output, evaluatedData: evaluatedOutput, actionsExecutionInfo: nil, executionDetails: ruleExecutionDetails)
    }

    private func evaluateOutputValue<T: Codable>(value: OutputValue, consumerContext: ConsumerContext) throws -> T? {
        let evaluationContext = consumerContext.getInputParamsModified()
        return try evaluateOutputValueInternal(value: value, evaluationContext: evaluationContext, consumerContext: consumerContext)
    }

    private func evaluateOutputValueInternal<T: Codable>(value: OutputValue, evaluationContext _: [String: Any], consumerContext _: ConsumerContext) throws -> T? {

        guard value.type == .nested else {
            throw RuleEngineError.generic(message: "Unsupported output type")
        }

        guard let value = value.value?.result else { return nil }

        guard value.type == .static else {
            throw RuleEngineError.generic(message: "Unsupported output value type in \(REUtils.toJson(value))")
        }

        guard let jsonString = value.value else { return nil }
        return try REUtils.fromJson(string: "\"\(jsonString)\"")
    }

    private func evaluateLoopCondition(condition: LoopConditionDetails?, consumerContext: ConsumerContext?) throws -> Bool {
        guard let loopTarget = try evaluateValue(value: condition?.loopTarget, consumerContext: consumerContext), let loopTargetArray = loopTarget.evaluatedValue as? [Any] else {
            throw RuleEngineError.generic(message: "Loop target must be a list")
        }

        guard let loopVariable = try evaluateValue(value: condition?.loopVariable, consumerContext: consumerContext), let loopVariableString = loopVariable.evaluatedValue as? String else {
            throw RuleEngineError.generic(message: "Loop variable must be a string")
        }

        guard let joinOperator = condition?.joinOperator else {
            throw RuleEngineError.generic(message: "Unsupported join operator")
        }

        switch joinOperator {
        case .allOf:
            return try loopTargetArray.allSatisfy {
                let updatedContext = consumerContext?.withLoopVariable(key: loopVariableString, value: $0)
                return try evaluateConditionsInternal(conditions: condition?.conditions ?? [], joinOperator: .allOf, consumerContext: updatedContext)
            }
        case .anyOf:
            return try loopTargetArray.contains {
                let updatedContext = consumerContext?.withLoopVariable(key: loopVariableString, value: $0)
                return try evaluateConditionsInternal(conditions: condition?.conditions ?? [], joinOperator: .anyOf, consumerContext: updatedContext)
            }
        }
    }

    private func evaluateConditionsInternal(conditions: [Condition], joinOperator: JoinOperator?, consumerContext: ConsumerContext?) throws -> Bool {
        guard let joinOperator else {
            throw RuleEngineError.generic(message: "Unsupported or nil join operator")
        }

        switch joinOperator {
        case .allOf:
            return try conditions.allSatisfy {
                try evaluateCondition(condition: $0, consumerContext: consumerContext).result == true
            }
        case .anyOf:
            return try conditions.contains {
                try evaluateCondition(condition: $0, consumerContext: consumerContext).result == true
            }
        }
    }

    private func evaluateConditions(conditions: [Condition], joinOperator: JoinOperator?, consumerContext: ConsumerContext?) throws -> EvaluateConditionsResult {

        if conditions.isEmpty {
            return EvaluateConditionsResult(conditions: conditions, result: true)
        }

        let result = try evaluateConditionsInternal(conditions: conditions, joinOperator: joinOperator, consumerContext: consumerContext)
        return EvaluateConditionsResult(conditions: conditions, result: result)
    }

    private func evaluateCondition(condition: Condition?, consumerContext: ConsumerContext?) throws -> EvaluateConditionResult {
        guard let conditionType = condition?.conditionType else {
            throw RuleEngineError.generic(message: "Unsupported condition type")
        }

        switch conditionType {
        case .join:
            let evaluateConditionsResult = try evaluateConditions(conditions: condition?.joinDetails?.conditions ?? [], joinOperator: condition?.joinDetails?.joinOperator, consumerContext: consumerContext)
            let conditionExecutionDetails = ConditionExecutionDetails(id: condition?.id, loopVariables: consumerContext?.loopVariables, evaluatedValues: [], result: evaluateConditionsResult.result)
            ruleExecutionDetails.conditionExecutions.append(conditionExecutionDetails)
            return EvaluateConditionResult(condition: condition, result: evaluateConditionsResult.result)
        case .filter:
            let result = try evaluateFilterCondition(id: condition?.id, filterDetails: condition?.filterDetails, consumerContext: consumerContext)
            return EvaluateConditionResult(condition: condition, result: result)
        case .loop:
            let result = try evaluateLoopCondition(condition: condition?.loopDetails, consumerContext: consumerContext)
            let conditionExecutionDetails = ConditionExecutionDetails(id: condition?.id, loopVariables: consumerContext?.loopVariables, evaluatedValues: [], result: result)
            ruleExecutionDetails.conditionExecutions.append(conditionExecutionDetails)
            return EvaluateConditionResult(condition: condition, result: result)
        }
    }

    private func evaluateFilterCondition(id: String?, filterDetails: FilterConditionDetails?, consumerContext: ConsumerContext?) throws -> Bool {

        guard let filterDetails,
              let filterOperator = filterDetails.operator
        else {
            throw RuleEngineError.generic(message: "Can't evaluate nil filter")
        }

        let resolvedOperandValues = try filterDetails.operands.map { try evaluateValue(value: $0, consumerContext: consumerContext) }
        let operand1 = resolvedOperandValues.count > 0 ? resolvedOperandValues[0] : nil
        let operand2 = resolvedOperandValues.count > 1 ? resolvedOperandValues[1] : nil

        let result = try evaluateFilterOperation(
            operator: filterOperator,
            operand1: operand1?.evaluatedValue,
            operand2: operand2?.evaluatedValue
        )
        let details = ConditionExecutionDetails(id: id, loopVariables: consumerContext?.loopVariables, evaluatedValues: resolvedOperandValues as [Any], result: result)
        ruleExecutionDetails.conditionExecutions.append(details)
        return result
    }

    private func evaluateFilterOperation(operator: FilterOperator, operand1: Any?, operand2: Any?) throws -> Bool {
        switch `operator` {
        case .isTrue:
            Operations.isTrue(operand: operand1)
        case .isFalse:
            Operations.isFalse(operand: operand1)
        case .equals:
            Operations.isEqual(operand1: operand1, operand2: operand2)
        case .notEquals:
            !Operations.isEqual(operand1: operand1, operand2: operand2)
        case .greaterThan:
            try Operations.isGreaterThan(operand1: operand1, operand2: operand2)
        case .lessThan, .lesserThan:
            try Operations.isLessThan(operand1: operand1, operand2: operand2)
        case .greaterThanOrEquals:
            try !Operations.isLessThan(operand1: operand1, operand2: operand2)
        case .lessThanOrEquals, .lesserThanOrEquals:
            try !Operations.isGreaterThan(operand1: operand1, operand2: operand2)
        case .contains:
            try Operations.isIn(operand1: operand2, operand2: operand1)
        case .notContains:
            try !Operations.isIn(operand1: operand2, operand2: operand1)
        case .isNull:
            Operations.isNull(operand: operand1)
        case .isNotNull:
            !Operations.isNull(operand: operand1)
        case .isIn:
            try Operations.isIn(operand1: operand1, operand2: operand2)
        case .isNotIn:
            try !Operations.isIn(operand1: operand1, operand2: operand2)
        }
    }

    private func evaluateValue(value: Value?, consumerContext: ConsumerContext?) throws -> EvaluateValueResult? {
        try ExpressionEvaluator.evaluateValue(value: value, consumerContext: consumerContext)
    }

    private struct EvaluateConditionsResult {
        let conditions: [Condition]
        let result: Bool?
    }

    private struct EvaluateConditionResult {
        let condition: Condition?
        let result: Bool?
    }
}
