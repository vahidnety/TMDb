//
//  SearchResult.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-11-04.
//

import Foundation

struct SearchResult: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}
