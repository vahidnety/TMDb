//
//  FavoritesViewController.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-11-02.
//

import UIKit


class FavoritesViewController: UIViewController, ErrorHandlingDelegate, FavoriteStatusDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: FavoritesViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure Table view
        configureTableView()
        
        // Initialize the viewModel with the MovieService
        viewModel = FavoritesViewModel(favoritesManager: FavoritesManager(),
                                      moviePlayingService: MovieService())
        
        fetchFavoriteMovies()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFavoriteMovies()
    }
    
    func fetchFavoriteMovies(){
        // Get favorite movies when the view loads
        viewModel.getFavoriteMovies()
        tableView.reloadData()
    }
    
    func configureTableView(){
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
                    detailVC.favoriteDelegate = self
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    func didChangeFavoriteStatus(for movie: Movie) {
        // Handle the change in favorite status here
        // Update the table view or UI as needed
        fetchFavoriteMovies()
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
                    cell.setNeedsLayout()
                }
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
            cell.stopLoading()
        }
        return cell
    }
}

