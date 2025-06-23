enum RuleEngineFactory {

    public static func createRuleSetExecutor<Output: Codable>() -> some RuleSetExecutor {
        return RuleSetExecutorImpl<Output>()
    }
}
