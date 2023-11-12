//
//  MovieTrailersResponse.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-11-11.
//

import Foundation

struct MovieTrailersResponse: Codable {
    let id: Int
    let results: [MovieTrailer]
}
