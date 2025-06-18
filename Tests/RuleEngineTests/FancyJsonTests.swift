import Foundation
@testable import RuleEngine
import Testing

enum Ant: String, Codable {
    case red = "RED"
    case black = "BLACK"
}

struct Cow: Codable {
    let name: String
    let colour: String
}

struct Elephant: Codable {
    let name: String
    let height: Float
    let weight: Double
}

struct UnknownCreature: Codable {
    let type: String
    let data: String?

    private enum CodingKeys: String, CodingKey {
        case type, data
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)

        if let dict = try? container.decode([String: AnyCodable].self, forKey: .data) {
            let nestedData = try JSONEncoder().encode(dict)
            data = String(data: nestedData, encoding: .utf8)
        } else if let nestedString = try? container.decode(String.self, forKey: .data) {
            data = "\"\(nestedString)\""
        } else {
            data = nil
        }
    }
}

@Suite("Fancy json parsing")
struct FancyJsonTests {

    @Test func example() async throws {

        let otherAnt = Ant.black
        let jsonData = try! JSONEncoder().encode(otherAnt)
        print(String(data: jsonData, encoding: .utf8) ?? "nil string")

        guard let ant = try? JSONDecoder().decode(Ant.self, from: "\"RED\"".data(using: .utf8)!) else {
            Issue.record("Failed to deserialise Ant")
            return
        }
        #expect(ant == .red, "Expect red ant")

        let ant2 = try? JSONDecoder().decode(Ant.self, from: "\"EXTRA\"".data(using: .utf8)!)
        #expect(ant2 == nil, "Unknown ant")
    }

    @Test func deserializeUnknownCreatures() async throws {

        // Test with a valid cow
        let jsonString1 = "{\"type\":\"Cow\",\"data\":{\"name\":\"Cow One\",\"colour\":\"White\"}}"
        guard let unknownCreature1 = try? JSONDecoder().decode(UnknownCreature.self, from: jsonString1.data(using: .utf8)!) else {
            Issue.record("Failed to deserialise string 1")
            return
        }
        #expect(unknownCreature1.type == "Cow", "Creature should be Cow")
        guard let cowJsonString = unknownCreature1.data else {
            Issue.record("Failed to access raw json in string 1")
            return
        }

        guard let cow = try? JSONDecoder().decode(Cow.self, from: cowJsonString.data(using: .utf8)!) else {
            Issue.record("Failed to deserialise cow from string 1")
            return
        }
        #expect(cow.colour == "White", "Match cow's colour")
        #expect(cow.name == "Cow One", "Match cow's name")

        // Test with a valid ant
        let jsonString2 = "{\"type\":\"Ant\",\"data\":\"BLACK\"}"
        guard let unknownCreature2 = try? JSONDecoder().decode(UnknownCreature.self, from: jsonString2.data(using: .utf8)!) else {
            Issue.record("Failed to deserialise string 2")
            return
        }
        #expect(unknownCreature2.type == "Ant", "Creature should be Ant")
        guard let antJsonString = unknownCreature2.data else {
            Issue.record("Failed to access raw json in string 2")
            return
        }
        guard let ant = try? JSONDecoder().decode(Ant.self, from: antJsonString.data(using: .utf8)!) else {
            Issue.record("Failed to deserialise ant from string 1")
            return
        }
        #expect(ant == .black, "Expect black ant")

        // Test with a valid elephant
        let jsonString3 = "{\"type\":\"Elephant\",\"data\":{\"name\":\"Fatty\",\"height\":3.5,\"weight\":3567.98}}"
        guard let unknownCreature3 = try? JSONDecoder().decode(UnknownCreature.self, from: jsonString3.data(using: .utf8)!) else {
            Issue.record("Failed to deserialise string 3")
            return
        }
        #expect(unknownCreature3.type == "Elephant", "Creature should be Elephant")
        guard let elephantJsonString = unknownCreature3.data else {
            Issue.record("Failed to access raw json in string 3")
            return
        }
        guard let elephant = try? JSONDecoder().decode(Elephant.self, from: elephantJsonString.data(using: .utf8)!) else {
            Issue.record("Failed to deserialise elephant from string 3")
            return
        }
        #expect(elephant.name == "Fatty", "Match elephant's name")
        #expect(elephant.height == 3.5, "Match elephant's height")
        #expect(elephant.weight == 3567.98, "Match elephant's weight")

        // Test with an invalid ant
        let jsonString4 = "{\"type\":\"Ant\",\"data\":\"PURPLE\"}"
        guard let unknownCreature4 = try? JSONDecoder().decode(UnknownCreature.self, from: jsonString4.data(using: .utf8)!) else {
            Issue.record("Failed to deserialise string 4")
            return
        }
        #expect(unknownCreature4.type == "Ant", "Creature should be Ant")
        guard let antJsonString2 = unknownCreature4.data else {
            Issue.record("Failed to access raw json in string 4")
            return
        }
        let ant2 = try? JSONDecoder().decode(Ant.self, from: antJsonString2.data(using: .utf8)!)
        #expect(ant2 == nil, "Expect nil ant")
    }
}
