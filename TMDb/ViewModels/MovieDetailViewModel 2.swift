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
    var favoriteDelegate: FavoriteStatusDelegate? { get set }

    func fetchMovieDetails(completion: @escaping (Result<Void, AppError>) -> Void)
    func toggleFavoriteStatus()
}

class MovieDetailViewModel: MovieDetailViewModelProtocol {
    private let movieDetailsService: MovieDetailsServiceProtocol
    private let favoritesManager: FavoritesManagerProtocol
    private(set) var movie: Movie
    private(set) var movieDetail: MovieDetail?
    private(set) var isFavorite: Bool
    
    // Declare the delegate property
    weak var errorDelegate: ErrorHandlingDelegate?
    weak var favoriteDelegate: FavoriteStatusDelegate?
    
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
                    self?.movieDetail = movieDetail
                    completion(.success(()))
                case .failure(let error):
                    // Handle error and pass it to the view
                    self?.errorDelegate?.viewModelDidFail(with: error)
                    completion(.failure(error))
            }
        }
    }
    
    func toggleFavoriteStatus() {
        if isFavorite {
            favoritesManager.removeMovieFromFavorites(movie)
        } else {
            favoritesManager.addMovieToFavorites(movie)
        }
        favoriteDelegate?.didChangeFavoriteStatus(for: movie)
        isFavorite.toggle()
    }
}
