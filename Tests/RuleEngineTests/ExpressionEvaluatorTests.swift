//
//  ExpressionEvaluatorTests.swift
//  RuleEngine
//
//  Created by Kanj on 12/06/25.
//
@testable import RuleEngine
import Testing

@Suite("Test expression evaluator")
struct ExpressionEvaluatorTests {

    @Test func accessValidProperties() async throws {

        let someNestedData: ConsumerContext = SomeNestedData()

        // Access integer
        let expression1 = Value(value: "${input.house.kitchen.windowCount}")
        let result1 = try ExpressionEvaluator.evaluateValue(value: expression1, consumerContext: someNestedData)
        let count = try #require(result1?.evaluatedValue as? Int, "Window count should not be nil")
        #expect(count == 1, "Window count should be 1")

        // Access value in a nested map
        let expression2 = Value(value: "${input.house.kitchen.appliances.chimney}")
        let result2 = try ExpressionEvaluator.evaluateValue(value: expression2, consumerContext: someNestedData)
        let chimney = try #require(result2?.evaluatedValue as? String, "Chimney name should not be nil")
        #expect(chimney == "Faber", "Chimney name should match")

        // Access value in a nested map
        let expression3 = Value(value: "${input.house.kitchen.appliances.fridge}")
        let result3 = try ExpressionEvaluator.evaluateValue(value: expression3, consumerContext: someNestedData)
        let fridge = try #require(result3?.evaluatedValue as? String, "Fridge name should not be nil")
        #expect(fridge == "Haier", "Fridge name should match")

        // Access integer
        let expression4 = Value(value: "${input.house.bedroom.bedCount}")
        let result4 = try ExpressionEvaluator.evaluateValue(value: expression4, consumerContext: someNestedData)
        let bedCount = try #require(result4?.evaluatedValue as? Int, "Bed count should not be nil")
        #expect(bedCount == 1, "Bed count should match")

        // Access object
        let expression5 = Value(value: "${input.house.bedroom}")
        let result5 = try ExpressionEvaluator.evaluateValue(value: expression5, consumerContext: someNestedData)
        let bedroom = try #require(result5?.evaluatedValue as? Bedroom, "Bedroom should not be nil")
        #expect(bedroom.bedCount == 1, "Bed count should match")

        // Access double
        let expression6 = Value(value: "${input.house.area}")
        let result6 = try ExpressionEvaluator.evaluateValue(value: expression6, consumerContext: someNestedData)
        let area = try #require(result6?.evaluatedValue as? Double, "Area should not be nil")
        #expect(area == 100.5, "Area should match")

        // Access string
        let expression7 = Value(value: "${input.house.address}")
        let result7 = try ExpressionEvaluator.evaluateValue(value: expression7, consumerContext: someNestedData)
        let address = try #require(result7?.evaluatedValue as? String, "Address should not be nil")
        #expect(address == "abc", "Address should match")

        // Access object in array
        let expression8 = Value(value: "${input.school.classes[0]}")
        let result8 = try ExpressionEvaluator.evaluateValue(value: expression8, consumerContext: someNestedData)
        let classroom = try #require(result8?.evaluatedValue as? Classroom, "Classroom should not be nil")
        #expect(classroom.studentCount == 10, "Student count should match")

        // Access integer in an object in array
        let expression9 = Value(value: "${input.school.classes[2].studentCount}")
        let result9 = try ExpressionEvaluator.evaluateValue(value: expression9, consumerContext: someNestedData)
        let studentCount = try #require(result9?.evaluatedValue as? Int, "Student count should not be nil")
        #expect(studentCount == 50, "Student count should match")

        // Access string in array
        let expression10 = Value(value: "${input.school.teachers[2]}")
        let result10 = try ExpressionEvaluator.evaluateValue(value: expression10, consumerContext: someNestedData)
        let teacher = try #require(result10?.evaluatedValue as? String, "Teacher name should not be nil")
        #expect(teacher == "C", "Teacher name should match")

        // Access integer in array
        let expression11 = Value(value: "${input.school.grades[9]}")
        let result11 = try ExpressionEvaluator.evaluateValue(value: expression11, consumerContext: someNestedData)
        let grade = try #require(result11?.evaluatedValue as? Int, "Grade should not be nil")
        #expect(grade == 10, "Grade should match")
    }

    @Test func trivialAccess() async throws {

        let someNestedData: ConsumerContext = SomeNestedData()

        let expression1 = Value(value: "${}")
        let result1 = try ExpressionEvaluator.evaluateValue(value: expression1, consumerContext: someNestedData)
        #expect(result1?.evaluatedValue == nil, "Evaluated value should be nil")

        let expression2 = Value(value: "${input}")
        let result2 = try ExpressionEvaluator.evaluateValue(value: expression2, consumerContext: someNestedData)
        let root = try #require(result2?.evaluatedValue as? [String: Any], "Root input should not be nil")
        let house = try #require(root["house"] as? House, "Root input should have a house")
        let school = try #require(root["school"] as? School, "Root input should have a school")
        let library = try #require(root["library"] as? Library, "Root input should have a library")
        #expect(house.kitchen.appliances.count == 2, "Number of appliances should match")
        #expect(school.grades.count == 10, "Number of grades should match")
        #expect(library.bookCount == 1000, "Number of books should match")

        let result3 = try ExpressionEvaluator.evaluateValue(value: nil, consumerContext: someNestedData)
        #expect(result3?.evaluatedValue == nil, "Evaluated value should be nil")

        let result4 = try ExpressionEvaluator.evaluateValue(value: nil, consumerContext: nil)
        #expect(result4?.evaluatedValue == nil, "Evaluated value should be nil")

        let expression5 = Value(value: nil)
        let result5 = try ExpressionEvaluator.evaluateValue(value: expression5, consumerContext: someNestedData)
        #expect(result5?.evaluatedValue == nil, "Evaluated value should be nil")

        let result6 = try ExpressionEvaluator.evaluateValue(value: expression5, consumerContext: nil)
        #expect(result6?.evaluatedValue == nil, "Evaluated value should be nil")

        let result7 = try ExpressionEvaluator.evaluateValue(value: expression1, consumerContext: nil)
        #expect(result7?.evaluatedValue == nil, "Evaluated value should be nil")
    }

    @Test func expressionEval() async throws {
        let expression = Value(value: "${input.lastKnownLocation}")
        let result = try ExpressionEvaluator.evaluateValue(value: expression, consumerContext: TestConsumerContext())
        #expect(result?.evaluatedValue == nil)
    }
}

struct SomeNestedData: ConsumerContext {

    let kitchen = Kitchen(windowCount: 1, appliances: ["fridge": "Haier", "chimney": "Faber"])
    var house: House {
        House(address: "abc", area: 100.5, kitchen: kitchen, bedroom: Bedroom(bedCount: 1))
    }

    let school = School(
        classes: [Classroom(studentCount: 10), Classroom(studentCount: 30), Classroom(studentCount: 50)],
        teachers: ["A", "B", "C", "D", "E"],
        grades: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    )
    let library = Library(bookCount: 1000)

    var inputParams: [String: Any] {
        [
            "house": house,
            "school": school,
            "library": library,
        ]
    }
}

struct House {
    let address: String
    let area: Double
    let kitchen: Kitchen
    let bedroom: Bedroom
}

struct School {
    let classes: [Classroom]
    let teachers: [String]
    let grades: [Int]
}

struct Kitchen {
    let windowCount: Int
    let appliances: [String: String]
}

struct Bedroom {
    let bedCount: Int
}

struct Library {
    let bookCount: Int
}

struct Classroom {
    let studentCount: Int
}
