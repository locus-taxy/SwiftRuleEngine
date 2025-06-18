public protocol ConsumerContext {
    var inputParams: [String: Any] { get }
    var loopVariables: [String: Any?] { get }
    func withLoopVariable(key: String, value: Any?) -> ConsumerContext
}

extension ConsumerContext {
    var loopVariables: [String: Any?] {
        [:]
    }

    func withLoopVariable(key _: String, value _: Any?) -> ConsumerContext {
        fatalError("Not implemented")
    }

    func getInputParamsModified() -> [String: Any] {
        ["input": inputParams]
    }
}

class WrappedConsumerContext: ConsumerContext {

    private let consumerContext: ConsumerContext
    var loopVariables = [String: Any?]()

    var inputParams: [String: Any] {
        consumerContext.inputParams
    }

    init(consumerContext: ConsumerContext) {
        self.consumerContext = consumerContext
    }

    func withLoopVariable(key: String, value: Any?) -> ConsumerContext {
        let context = WrappedConsumerContext(consumerContext: consumerContext)
        context.loopVariables = loopVariables
        context.loopVariables[key] = value
        return context
    }
}
