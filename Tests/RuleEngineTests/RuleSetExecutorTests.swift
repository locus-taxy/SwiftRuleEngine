//
//  RuleSetExecutorTests.swift
//  RuleEngine
//
//  Created by Kanj on 18/06/25.
//
import Foundation
@testable import RuleEngine
import Testing

@Suite("Test rule set executor")
struct RuleSetExecutorTests {

    @Test func basic() async throws {
        let ruleSet: RuleSet = try loadJSON(filename: "sample-rule-set")
        let executor = RuleSetExecutorImpl<TestResult>()

        let result1 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result1 == .blockWithReasonUnknown)

        let result2 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(location: TestLocation(lat: 100.5, lng: 100.5)),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result2 == .proceed)
    }
}

struct TestConsumerContext: ConsumerContext {

    private let location: TestLocation?

    init(location: TestLocation? = nil) {
        self.location = location
    }

    var inputParams: [String: Any] {

        guard let location = self.location else { return [:] }
        return [
            "lastKnownLocation": location,
        ]
    }
}

struct TestLocation: Codable {
    let lat: Double
    let lng: Double
}

enum TestResult: String, Codable {
    case blockWithReasonUnknown = "BLOCK_WITH_REASON_UNKNOWN"
    case proceed = "PROCEED"
}

struct TestTimeZoneProvider: TimeZoneProvider {
    var timezone = "IST"
    var dateFormat = "en"
}
