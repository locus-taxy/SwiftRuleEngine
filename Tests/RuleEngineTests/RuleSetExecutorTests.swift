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

        let testTour1 = TestExtendedTour(status: TestExtendedTourStatus(status: .queued))
        let result1 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(tour: testTour1),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result1 == .proceed)

        let testTour2 = TestExtendedTour(status: TestExtendedTourStatus(status: .started))
        let result2 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(tour: testTour2),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result2 == nil)

        let testTour3 = TestExtendedTour(status: TestExtendedTourStatus(status: nil))
        let result3 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(tour: testTour3),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result3 == nil)

        let testTour4 = TestExtendedTour(status: nil)
        #expect(throws: RuleEngineError.self, performing: {
            try executor.executeFirstMatch(
                clientId: "clientId", ruleSet: ruleSet,
                consumerContext: TestConsumerContext(tour: testTour4),
                timeZoneProvider: TestTimeZoneProvider()
            )
        })

        #expect(throws: RuleEngineError.self, performing: {
            try executor.executeFirstMatch(
                clientId: "clientId", ruleSet: ruleSet,
                consumerContext: TestConsumerContext(),
                timeZoneProvider: TestTimeZoneProvider()
            )
        })
    }

    @Test func testSample3() async throws {
        let ruleSet: RuleSet = try loadJSON(filename: "sample-rule-set-3")
        let executor = RuleSetExecutorImpl<TestResult>()

        let result1 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(visitStatus: .started),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result1 == .proceed)

        let result2 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(visitStatus: .arrived),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result2 == .proceed)

        let result3 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(visitStatus: .transacting),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result3 == .proceed)

        let result4 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(visitStatus: .completed),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result4 == .proceedWithConfirmation)

        let result5 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(visitStatus: .accepted),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result5 == nil)

        let result6 = try executor.executeFirstMatch(
            clientId: "clientId", ruleSet: ruleSet,
            consumerContext: TestConsumerContext(),
            timeZoneProvider: TestTimeZoneProvider()
        )
        #expect(result6 == nil)
    }
}

struct TestConsumerContext: ConsumerContext {

    private let location: TestLocation?
    private let tour: TestExtendedTour?
    private let visitStatus: TestVisitStatus?

    init(location: TestLocation? = nil, tour: TestExtendedTour? = nil, visitStatus: TestVisitStatus? = nil) {
        self.location = location
        self.tour = tour
        self.visitStatus = visitStatus
    }

    var inputParams: [String: Any] {
        var inputs = [String: Any]()
        inputs["lastKnownLocation"] = location
        inputs["extendedTour"] = tour
        inputs["nextVisitStatus"] = visitStatus
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

enum TestVisitStatus: String, Codable {
    case received = "RECEIVED"
    case waiting = "WAITING"
    case accepted = "ACCEPTED"
    case started = "STARTED"
    case arrived = "ARRIVED"
    case transacting = "TRANSACTING"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
}

enum TestResult: String, Codable {
    case blockWithReasonUnknown = "BLOCK_WITH_REASON_UNKNOWN"
    case proceed = "PROCEED"
    case proceedWithConfirmation = "PROCEED_WITH_CONFIRMATION"
}

struct TestTimeZoneProvider: TimeZoneProvider {
    var timezone = "IST"
    var dateFormat = "en"
}
