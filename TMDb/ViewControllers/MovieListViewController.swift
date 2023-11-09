//
//  MovieListViewController.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//

import UIKit
import SkeletonView

class MovieListViewController: UIViewController, ErrorHandlingDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: MovieListViewModelProtocol!
    var settingsViewModel: SettingsViewModelProtocol!
    var sortOption: SortOption = SortOption(rawValue: 0)!
    var filterOption: FilterOption = FilterOption(rawValue: 0)!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialisation()
        
        //Setup Table view
        setupUI()
        
        addRefresh()

        // Fetch now playing movies when the view loads
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
            self.fetchMovies()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        extractFilterSortOptionsUpdateTable()
    }
    
    private func initialisation(){
        settingsViewModel = SettingsViewModel()
        self.tabBarController?.delegate = self
        
        // Initialize the viewModel with the MovieService
        viewModel = MovieListViewModel(moviePlayingService: MovieService())
        viewModel.errorDelegate = self
    }
    
    private func addRefresh(){
        // Add a refresh control to the table view
        addRefreshControl(to: self.tableView, action: #selector(refreshData))
        
        // Customize the refresh control appearance
        // customizeRefreshControl(for: self.tableView, tintColor: .blue, backgroundColor: .white)
    }
    
    @objc private func refreshData() {
        // When you want to start the refresh manually
        //        self.startRefreshing(for: self.tableView)
        
        // Handle the refresh action, e.g., fetch new data from the server
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
            self.fetchMovies()
        }
    }
    
    internal func fetchMovies(){
        
        // Fetch the list of now playing movies
        // The [weak self] is used to avoid a strong reference cycle (retain cycle)
        // and ensure that self (the view controller) can be deallocated when it's no longer needed.
        viewModel.fetchNowPlayingMovies(sortOption: sortOption.description, filterOption: filterOption.description){
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
            // When the refresh operation is complete
            DispatchQueue.main.async {
                self?.stopRefreshing(for: self!.tableView)
            }
        }
    }
    
    private func setupUI(){
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 170
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isSkeletonable = true
        tableView.showAnimatedSkeleton()
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
        else if segue.identifier == "ShowSearch" {
            if let searchVC = segue.destination as? SearchViewController {
                searchVC.settingsViewModel = settingsViewModel
            }
        }
    }
    
    func extractFilterSortOptionsUpdateTable() {
        let newSortOption = settingsViewModel.sortOption
        let newFilterOption = settingsViewModel.filterOption

        if sortOption != newSortOption || filterOption != newFilterOption {
            sortOption = newSortOption
            filterOption = newFilterOption
            
            fetchMovies()
            tableView.reloadData()
        }
    }
}

extension MovieListViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController,
           let tabViewController = navController.viewControllers.first as? SettingsViewController {
            // Access the view model of the tab view controller and set it
            tabViewController.viewModel = settingsViewModel
        }
    }
}

extension MovieListViewController: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "MovieCell"
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

