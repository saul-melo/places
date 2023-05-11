//
//  Result.swift
//  Places
//
//  Created by melo on 5/3/23.
//

import Foundation

struct Result: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [Int: Page]
}

struct Page: Codable, Comparable {
    static func < (lhs: Page, rhs: Page) -> Bool {
        lhs.title < rhs.title
    }
    
    let pageid: Int
    let title: String
    let terms: [String: [String]]?
    var description: String {
        terms?["description"]?.first ?? "no further information"
    }
}
