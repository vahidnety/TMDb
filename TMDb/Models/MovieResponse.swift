//
//  MovieResponse.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//

import Foundation

struct MovieResponse: Codable  {
    let dates: MovieDateRange?
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}

struct MovieDateRange: Codable  {
    let maximum: String
    let minimum: String
}
