//
//  FavoritesViewModel.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//

import Foundation
import UIKit

protocol FavoritesViewModelProtocol {
    var movies: [Movie] { get }
    var errorDelegate: ErrorHandlingDelegate? { get set }
    
    func getFavoriteMovies()
    func loadImage(for movie: Movie, completion: @escaping (Result<UIImage, AppError>) -> Void)
}

class FavoritesViewModel: FavoritesViewModelProtocol {
    private let moviePlayingService: MoviePlayingServiceProtocol
    private let favoritesManager: FavoritesManagerProtocol
    private(set) var movies: [Movie] = []
    
    weak var errorDelegate: ErrorHandlingDelegate?
    
    init(favoritesManager: FavoritesManagerProtocol, moviePlayingService: MoviePlayingServiceProtocol) {
        self.favoritesManager = favoritesManager
        self.moviePlayingService = moviePlayingService
    }
    
    func getFavoriteMovies() {
        movies = favoritesManager.getFavoriteMovies()
    }
   
    
    func loadImage(for movie: Movie, completion: @escaping (Result<UIImage, AppError>) -> Void) {
        guard let urlPath = movie.posterPath else {
            completion(.success(UIImage(named: "placeholderImage") ?? UIImage()))
            return
        }
        moviePlayingService.downloadMovieImage(from: urlPath) {
            [weak self] result in
            switch result {
                case .success(let image):
                    completion(.success(image))
                case .failure(let error):
                    // Handle error and pass it to the view
                    self?.errorDelegate?.viewModelDidFail(with: error)//self is not strongly captured by the closure //errorDelegate itself is a weak reference // Notify the error delegate
                    completion(.failure(error))
            }
        }
    }
}
