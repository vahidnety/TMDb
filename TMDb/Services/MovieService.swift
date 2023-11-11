//
//  MovieService.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//

import Foundation
import UIKit

protocol MoviePlayingServiceProtocol {
    func fetchNowPlayingMovies(page: Int, sortOption: String?, filterOption: String?,
                               completion: @escaping (Result<[Movie], AppError>) -> Void)
    func downloadMovieImage(from endpointString: String?, completion: @escaping (Result<UIImage, AppError>) -> Void)
}

protocol MovieDetailsServiceProtocol {
    func fetchMovieDetails(movieID: Int, completion: @escaping (Result<MovieDetail, AppError>) -> Void)
}

protocol SearchServiceProtocol {
    func searchMovies(page: Int, sortOption: String?, filterOption: String?,
                      withQuery query: String, completion: @escaping (Result<[Movie], AppError>) -> Void)
}

class MovieService: MoviePlayingServiceProtocol, MovieDetailsServiceProtocol, SearchServiceProtocol  {
    private let apiKey = "8765536cf9830a3ff1945261baabe026"
    private let baseURL = "https://api.themoviedb.org/3/"
    private let baseImageURL = "https://image.tmdb.org/t/p/w500"
    
    private let session: URLSession
    private let cache: URLCache
    
    init(session: URLSession = .shared, cache: URLCache = .shared) {
        self.session = session
        self.cache = cache
    }
    
    func fetchNowPlayingMovies(page: Int, sortOption: String?, filterOption: String?,
                               completion: @escaping (Result<[Movie], AppError>) -> Void) {
        let sortOption = sortOption == nil || sortOption == "defaultSort" ? "" : "&sort_by=" + sortOption!.lowercased() + ".desc"
        let filterOption = filterOption == nil || filterOption == "defaultFilter" ? "" : "&year=" + filterOption!.lowercased()
        //&sort_by=popularity.desc
        //&year=2020
        ///discover/movie
        ///movie/now_playing
        var discovery = "movie/now_playing"
        if sortOption != "" || filterOption != "" {
            discovery = "discover/movie"
        }
        let url = URL(string: "\(baseURL)\(discovery)?page=\(page)&api_key=\(apiKey)\(sortOption)\(filterOption)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let movies = try decoder.decode(MovieResponse.self, from: data)
                    completion(.success(movies.results))
                } catch {
                    completion(.failure(AppError.parsingError))
                }
            } else if let error = error {
                completion(.failure(AppError.other(error.localizedDescription)))
            }
        }.resume()
    }
    
    func fetchMovieDetails(movieID: Int, completion: @escaping (Result<MovieDetail, AppError>) -> Void) {
        // Implement the network request to fetch detailed information for a movie by its ID
        // Call the completion handler with the fetched data or an error
        let urlString = "\(baseURL)movie/\(movieID)?api_key=\(apiKey)"
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let movieDetail = try decoder.decode(MovieDetail.self, from: data)
                        completion(.success(movieDetail))
                    } catch {
                        completion(.failure(AppError.parsingError))
                    }
                } else if let error = error {
                    completion(.failure(AppError.other(error.localizedDescription)))
                }
            }.resume()
        }
    }
    
    func downloadMovieImage(from endpointString: String?, completion: @escaping (Result<UIImage, AppError>) -> Void) {
        guard let endpointString = endpointString, let urlPath = URL(string: baseImageURL + endpointString) else{
            completion(.failure(AppError.other("URL String error!")))
            return
        }
        let request = URLRequest(url: urlPath)
        if let cachedResponse = cache.cachedResponse(for: request) {
            if let image = UIImage(data: cachedResponse.data) {
                completion(.success(image))
                return
            }
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data, let response = response {
                let cachedData = CachedURLResponse(response: response, data: data)
                self.cache.storeCachedResponse(cachedData, for: request)
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(AppError.dataNotFound))
                }
            } else {
                completion(.failure(AppError.networkError))
            }
        }
        task.resume()
    }
    
    func searchMovies(page: Int, sortOption: String?, filterOption: String?,
                      withQuery query: String, completion: @escaping (Result<[Movie], AppError>) -> Void) {
        let sortOption = sortOption == nil || sortOption == "defaultSort" ? "" : "&sort_by=" + sortOption!.lowercased() + ".desc"
        let filterOption = filterOption == nil || filterOption == "defaultFilter" ? "" : "&year=" + filterOption!.lowercased()
        
        let urlString = baseURL + "search/movie" + "?query=\(query)" + "&page=\(page)" + "&api_key=\(apiKey)" + "\(sortOption)\(filterOption)"
        guard let url = URL(string: urlString) else {
            completion(.failure(AppError.networkError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(AppError.other(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(AppError.dataNotFound))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let searchResult = try decoder.decode(SearchResult.self, from: data)
                completion(.success(searchResult.results))
            } catch {
                completion(.failure(AppError.parsingError))
            }
        }.resume()
    }
}
