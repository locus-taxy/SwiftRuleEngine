//
//  Utils.swift
//  LocusDeliveryApp
//
//  Created by Kanj on 23/04/25.
//
import Foundation
@testable import RuleEngine

func loadJSON<T: Decodable>(filename: String) throws -> T {
    guard let url = Bundle.module.url(forResource: "Json/\(filename)", withExtension: "json") else {
        throw NSError(domain: "FileError", code: 2, userInfo: [NSLocalizedDescriptionKey: "File \(filename).json not found in bundle"])
    }

    let data = try Data(contentsOf: url)
    return try REUtils.fromJson(data: data)!
}
