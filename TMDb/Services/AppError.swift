//
//  AppError.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-29.
//

import Foundation

enum AppError: Error {
    case networkError
    case parsingError
    case dataNotFound
    case other(String)
}
