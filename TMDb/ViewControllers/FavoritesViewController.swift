//
//  FavoritesViewController.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-11-02.
//

import UIKit

class FavoritesViewController: UIViewController, ErrorHandlingDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyFavorites: UILabel!
    
    var viewModel: FavoritesViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(valueDidChange(_:)), name: Notification.Name("ValueDidChangeNotification"), object: nil)
        
        //Configure Table view
        configureTableView()
        
        // Initialize the viewModel with the MovieService
        viewModel = FavoritesViewModel(favoritesManager: FavoritesManager(),
                                       moviePlayingService: MovieService())
        
        fetchFavoriteMovies()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ValueDidChangeNotification"), object: nil)
    }
    
    @objc private func valueDidChange(_ notification: Notification) {
        if let userInfo = notification.userInfo, let newValue = userInfo["FavoritesChanged"] as? Bool {
            // Check the new value and react accordingly
            if newValue {
                // Value is now true
                fetchFavoriteMovies()
            } else {
                // Value is now false
            }
        }
    }
    
    private func fetchFavoriteMovies() {
        NotificationCenter.default.post(name: Notification.Name("ValueDidChangeNotification"), object: nil, userInfo: ["FavoritesChanged": false])
        
        // Get favorite movies when the view loads
        viewModel.getFavoriteMovies()
        tableView.reloadData()
        
        if tableView.numberOfRows(inSection: 0) > 0 {
            emptyFavorites.isHidden = true
        }
        else {
            emptyFavorites.isHidden = false
        }
    }
    
    private func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedMovie = viewModel.movies[indexPath.row]
                
                if let detailVC = segue.destination as? MovieDetailViewController {
                    let detailViewModel = MovieDetailViewModel(
                        movie: selectedMovie,
                        movieDetailsService: MovieService(), // Initialize your movie service
                        favoritesManager: FavoritesManager() // Initialize your favorites manager
                    )
                    detailVC.viewModel = detailViewModel
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableCell
        let movie = viewModel.movies[indexPath.row]
        cell.startLoading()
        
        cell.configure(with: movie, image: nil)
        
        viewModel.loadImage(for: movie) { result in
            switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        cell.configure(with: movie, image: image)
                        //                    cell.setNeedsLayout()
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
            }
            cell.stopLoading()
        }
        return cell
    }
}

