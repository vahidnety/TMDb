//
//  MovieListViewModel.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//

import Foundation
import UIKit

protocol MovieListViewModelProtocol {
    var movies: [Movie] { get }
    var errorDelegate: ErrorHandlingDelegate? { get set }
    
    func fetchNowPlayingMovies(sortOption: String?, filterOption: String?,
                               completion: @escaping (Result<Void, AppError>) -> Void)
    func loadImage(for movie: Movie, completion: @escaping (Result<UIImage, AppError>) -> Void)
}


class MovieListViewModel: MovieListViewModelProtocol {
    
    private let moviePlayingService: MoviePlayingServiceProtocol
    
    private(set) var movies: [Movie] = []
    
    weak var errorDelegate: ErrorHandlingDelegate?
    
    init(moviePlayingService: MoviePlayingServiceProtocol) {
        self.moviePlayingService = moviePlayingService
    }
    
    func fetchNowPlayingMovies(sortOption: String?, filterOption: String?,
                               completion: @escaping (Result<Void, AppError>) -> Void){
        moviePlayingService.fetchNowPlayingMovies(sortOption: sortOption, filterOption: filterOption) {
            [weak self] result in
            switch result {
                case .success(let movies):
                    self?.movies = movies
                    completion(.success(()))
                case .failure(let error):
                    // Handle error and pass it to the view
                    self?.errorDelegate?.viewModelDidFail(with: error)
                    completion(.failure(error))
            }
        }
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
