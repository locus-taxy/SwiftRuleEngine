enum RuleEngineFactory<Output: Codable> {

    public static func createRuleSetExecutor() -> some RuleSetExecutor {
        return RuleSetExecutorImpl<Output>()
    }
}
