//
//  MovieDetailViewModel.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//

import Foundation

protocol MovieDetailViewModelProtocol {
    var movie: Movie { get }
    var movieDetail: MovieDetail? { get }
    var isFavorite: Bool { get }
    var errorDelegate: ErrorHandlingDelegate? { get set }
    
    func fetchMovieDetails(completion: @escaping (Result<Void, AppError>) -> Void)
    func fetchTrailers()
    func toggleFavoriteStatus()
    func getFavoriteStatus()
    var onTrailersUpdate: (([MovieTrailer]) -> Void)? { get set } // Include the closure property
    var videoID: String? { get }
}

class MovieDetailViewModel: MovieDetailViewModelProtocol {
    
    private let movieDetailsService: MovieDetailsServiceProtocol

    private let favoritesManager: FavoritesManagerProtocol
    private(set) var movie: Movie
    private(set) var movieDetail: MovieDetail?
    private(set) var isFavorite: Bool
    private var trailers: [MovieTrailer] = [] // Assuming your view model will hold the fetched trailers
    
    // Closure property to inform about trailer updates
    var onTrailersUpdate: (([MovieTrailer]) -> Void)?
    
    var videoID: String?

    // Declare the delegate property
    weak var errorDelegate: ErrorHandlingDelegate?
    
    init(movie: Movie, movieDetailsService: MovieDetailsServiceProtocol,
         favoritesManager: FavoritesManagerProtocol) {
        self.movie = movie
        self.movieDetailsService = movieDetailsService
        self.favoritesManager = favoritesManager
        self.isFavorite = favoritesManager.isMovieFavorite(movie)
    }
    
    func fetchMovieDetails(completion: @escaping (Result<Void, AppError>) -> Void) {
        movieDetailsService.fetchMovieDetails(movieID: movie.id) {
            [weak self] result in
            switch result {
                case .success(let movieDetail):
                    self?.getFavoriteStatus()
                    self?.movieDetail = movieDetail
                    completion(.success(()))
                case .failure(let error):
                    // Handle error and pass it to the view
                    self?.errorDelegate?.viewModelDidFail(with: error)
                    completion(.failure(error))
            }
        }
    }
    
    func fetchTrailers() {
        movieDetailsService.fetchMovieTrailers(movieID: movie.id) {
            [weak self] result in
            switch result {
                case .success(let trailers):
                    self?.trailers = trailers
                    self?.videoID = trailers[0].key
                    // Call the closure to notify the view or view controller
                    self?.onTrailersUpdate?(trailers)
                case .failure(let error):
                    // Handle error and pass it to the view
                    self?.errorDelegate?.viewModelDidFail(with: error)
            }
        }
    }
    
    func getFavoriteStatus() {
        self.isFavorite = favoritesManager.isMovieFavorite(movie)
    }
    
    func toggleFavoriteStatus() {
        if isFavorite {
            favoritesManager.removeMovieFromFavorites(movie)
        } else {
            favoritesManager.addMovieToFavorites(movie)
        }
        isFavorite.toggle()
    }
}
