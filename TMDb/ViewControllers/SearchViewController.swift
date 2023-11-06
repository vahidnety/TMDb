//
//  SearchViewController.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-11-04.
//

import Foundation
import UIKit

class SearchViewController: UIViewController, ErrorHandlingDelegate{//?, SettingsViewModelDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: SearchViewModelProtocol!
    var settingsViewModel: SettingsViewModelProtocol!
    var sortOption: SortOption = SortOption(rawValue: 0)!
    var filterOption: FilterOption = FilterOption(rawValue: 0)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialisation()
        
        //Setup Table view and search bar
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        extractFilterSortOptionsUpdateTable()
        
    }
    
    private func initialisation(){
//        settingsViewModel = SettingsViewModel()
//        settingsViewModel.delegate = self
        self.tabBarController?.delegate = self
        
        // Initialize the viewModel with the MovieService
        viewModel = SearchViewModel(searchService: MovieService())
        viewModel.errorDelegate = self
    }
    
    private func setupUI() {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedMovie = viewModel.searchResults[indexPath.row]
                //delegate?.didSelectMovie(selectedMovie)
                
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
    
    func extractFilterSortOptionsUpdateTable() {
        let newSortOption = settingsViewModel.sortOption
        let newFilterOption = settingsViewModel.filterOption
        
        if sortOption != newSortOption || filterOption != newFilterOption {
            sortOption = newSortOption
            filterOption = newFilterOption
            
            searchMovies(withQuery: searchBar.text ?? "")
        }
    }
}

extension SearchViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController,
           let tabViewController = navController.viewControllers.first as? SettingsViewController {
            // Access the view model of the tab view controller and set it
            tabViewController.viewModel = settingsViewModel
        }
    }
}

extension SearchViewController: UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource  {
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text, !query.isEmpty {
            searchMovies(withQuery: query)
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableCell
        let movie = viewModel.searchResults[indexPath.row]
        
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
    
    // MARK: - Helper Methods
    
    func searchMovies(withQuery query: String) {
        viewModel.searchMovies(sortOption: sortOption.description, filterOption: filterOption.description,
                               query: query){
            [weak self] result in
            switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
            }
        }
    }
}
