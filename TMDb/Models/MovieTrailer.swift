//
//  MovieTrailer.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-11-11.
//

import Foundation

struct MovieTrailer: Codable {
    let iso_639_1: String
    let iso_3166_1: String
    let name: String
    let key: String
    let site: String
    let size: Int
    let type: String
    let official: Bool
    let published_at: String
    let id: String
}
