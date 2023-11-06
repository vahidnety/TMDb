//
//  MovieDetailFetcher.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//

import Foundation

protocol MovieDetailFetcherProtocol {
    func fetchMovieDetails(movieID: Int, completion: @escaping (Result<MovieDetail, AppError>) -> Void)
}

class MovieDetailFetcher: MovieDetailFetcherProtocol {
    private let movieDetailsService: MovieDetailsServiceProtocol
    
    init(movieDetailsService: MovieDetailsServiceProtocol) {
        self.movieDetailsService = movieDetailsService
    }
    
    func fetchMovieDetails(movieID: Int, completion: @escaping (Result<MovieDetail, AppError>) -> Void) {
        movieDetailsService.fetchMovieDetails(movieID: movieID, completion: completion)
    }
}
