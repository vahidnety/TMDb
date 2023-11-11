//
//  SearchViewModel.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-11-04.
//

import Foundation
import UIKit

protocol SearchViewModelProtocol {
    var searchResults: [Movie] { get }
    func searchMovies(page: Int, sortOption: String?, filterOption: String?,
                      query: String, completion: @escaping (Result<Void, AppError>) -> Void)
    func fetchNextPageOfSearchMovies(page: Int, sortOption: String?, filterOption: String?,
                                     query: String, completion: @escaping (Result<Void, AppError>) -> Void)
    var errorDelegate: ErrorHandlingDelegate? { get set }
    func loadImage(for movie: Movie, completion: @escaping (Result<UIImage, AppError>) -> Void)
}

class SearchViewModel: SearchViewModelProtocol {
    private(set) var searchResults: [Movie] = []
    weak var errorDelegate: ErrorHandlingDelegate?
    
    private let searchService: SearchServiceProtocol & MoviePlayingServiceProtocol
    private var currentPage: Int = 1

    init(searchService: SearchServiceProtocol & MoviePlayingServiceProtocol) {
        self.searchService = searchService
    }
    
    func fetchNextPageOfSearchMovies(page: Int, sortOption: String?, filterOption: String?,
                      query: String, completion: @escaping (Result<Void, AppError>) -> Void) {
        currentPage += 1
        searchService.searchMovies(page: currentPage, sortOption: sortOption, filterOption: filterOption, withQuery: query) {
            [weak self] result in
            switch result {
                case .success(let movies):
                    self?.searchResults.append(contentsOf: movies)
                    completion(.success(()))
                case .failure(let error):
                    // Handle error and pass it to the view
                    self?.errorDelegate?.viewModelDidFail(with: error)
                    completion(.failure(error))
            }
        }
    }
    
    func searchMovies(page: Int, sortOption: String?, filterOption: String?,
                      query: String, completion: @escaping (Result<Void, AppError>) -> Void) {
        searchService.searchMovies(page: page, sortOption: sortOption, filterOption: filterOption, withQuery: query) {
            [weak self] result in
            switch result {
                case .success(let movies):
                    self?.searchResults = movies
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
        searchService.downloadMovieImage(from: urlPath) {
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

