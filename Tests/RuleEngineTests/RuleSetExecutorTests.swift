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

    @Test func testSample1() async throws {
        let ruleSet: RuleSet = try loadJSON(filename: "sample-rule-set-1")
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

    @Test func testSample2() async throws {
        let ruleSet: RuleSet = try loadJSON(filename: "sample-rule-set-2")
        let executor = RuleSetExecutorImpl<TestResult>()

        let testTour = TestExtendedTour(status: TestExtendedTourStatus(status: .queued))
        let result1 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(tour: testTour),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result1 == .proceed)
    }
}

struct TestConsumerContext: ConsumerContext {

    private let location: TestLocation?
    private let tour: TestExtendedTour?

    init(location: TestLocation? = nil, tour: TestExtendedTour? = nil) {
        self.location = location
        self.tour = tour
    }

    var inputParams: [String: Any] {

        var inputs = [String: Any]()

        if let location = self.location {
            inputs["lastKnownLocation"] = location
        }

        if let extendedTour = self.tour {
            inputs["extendedTour"] = extendedTour
        }

        return inputs
    }
}

struct TestLocation: Codable {
    let lat: Double
    let lng: Double
}

struct TestExtendedTour: Codable {
    let status: TestExtendedTourStatus?
}

struct TestExtendedTourStatus: Codable {
    let status: TestTourStatus?
}

enum TestTourStatus: String, Codable {
    case queued = "QUEUED"
    case started = "STARTED"
    case completed = "COMPLETED"
}

enum TestResult: String, Codable {
    case blockWithReasonUnknown = "BLOCK_WITH_REASON_UNKNOWN"
    case proceed = "PROCEED"
}

struct TestTimeZoneProvider: TimeZoneProvider {
    var timezone = "IST"
    var dateFormat = "en"
}
