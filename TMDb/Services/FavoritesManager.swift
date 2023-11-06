//
//  FavoritesManager.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//

import Foundation

protocol FavoritesManagerProtocol {
    func addMovieToFavorites(_ movie: Movie)
    func removeMovieFromFavorites(_ movie: Movie)
    func getFavoriteMovies() -> [Movie]
    func isMovieFavorite(_ movie: Movie) -> Bool
}

class FavoritesManager: FavoritesManagerProtocol {    
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteMovies"
    
    func isMovieFavorite(_ movie: Movie) -> Bool {
        let favoriteMovies = getFavoriteMovies()
        return favoriteMovies.contains(where: { $0.id == movie.id })
    }
    
    func addMovieToFavorites(_ movie: Movie) {
        var favoriteMovies = getFavoriteMovies()
        if !favoriteMovies.contains(where: { $0.id == movie.id }) {
            favoriteMovies.append(movie)
            saveFavoriteMovies(favoriteMovies)
        }
    }
    
    func removeMovieFromFavorites(_ movie: Movie) {
        var favoriteMovies = getFavoriteMovies()
        if let index = favoriteMovies.firstIndex(where: { $0.id == movie.id }) {
            favoriteMovies.remove(at: index)
            saveFavoriteMovies(favoriteMovies)
        }
    }
    
    func getFavoriteMovies() -> [Movie] {
        if let favoriteMovieData = userDefaults.data(forKey: favoritesKey) {
            let decoder = JSONDecoder()
            if let favoriteMovies = try? decoder.decode([Movie].self, from: favoriteMovieData) {
                return favoriteMovies
            }
        }
        return []
    }
    
    private func saveFavoriteMovies(_ favoriteMovies: [Movie]) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(favoriteMovies) {
            userDefaults.set(encodedData, forKey: favoritesKey)
            NotificationCenter.default.post(name: Notification.Name("ValueDidChangeNotification"), object: nil, userInfo: ["FavoritesChanged": true])

        }
    }
}

