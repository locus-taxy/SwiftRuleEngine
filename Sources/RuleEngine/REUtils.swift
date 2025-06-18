//
//  REUtils.swift
//  RuleEngine
//
//  Created by Kanj on 17/06/25.
//
import Foundation

enum REUtils {

    private static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    static func toJson(_ object: Encodable) -> String {
        guard let data = try? jsonEncoder.encode(object) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func fromJson<T: Decodable>(string: String) throws -> T? {
        guard let data = string.data(using: .utf8) else { return nil }
        return try jsonDecoder.decode(T.self, from: data)
    }

    static func fromJson<T: Decodable>(data: Data) throws -> T? {
        try jsonDecoder.decode(T.self, from: data)
    }
}
