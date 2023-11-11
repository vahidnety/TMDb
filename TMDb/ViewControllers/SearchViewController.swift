//
//  SearchViewController.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-11-04.
//

import Foundation
import UIKit
import SkeletonView

class SearchViewController: UIViewController, ErrorHandlingDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyResults: UILabel!
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
        self.tabBarController?.delegate = self
        
        // Initialize the viewModel with the MovieService
        viewModel = SearchViewModel(searchService: MovieService())
        viewModel.errorDelegate = self
    }
    
    private func setupUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 170
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isSkeletonable = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedMovie = viewModel.searchResults[indexPath.row]
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

extension SearchViewController: UISearchBarDelegate, SkeletonTableViewDataSource, SkeletonTableViewDelegate {
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
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "MovieCell"
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = viewModel.searchResults.count - 1
        if indexPath.row == lastElement {
            viewModel.fetchNextPageOfSearchMovies(page:1, sortOption: sortOption.description, filterOption: filterOption.description, query: searchBar.text ?? ""){
                [weak self] result in
                switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self?.tableView.stopSkeletonAnimation()
                            self?.tableView.hideSkeleton()
                            self?.tableView.reloadData()
                        }
                    case .failure(let error):
                        print("error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func searchMovies(withQuery query: String) {
        tableView.showAnimatedSkeleton()

        viewModel.searchMovies(page:1, sortOption: sortOption.description, filterOption: filterOption.description,
                               query: query){
            [weak self] result in
            switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.tableView.stopSkeletonAnimation()
                        self?.tableView.hideSkeleton()
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
            }
        }
        if tableView.numberOfRows(inSection: 0) > 0 {
            emptyResults.isHidden = true
        }
        else {
            emptyResults.isHidden = false
        }
    }
}
