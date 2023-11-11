//
//  MovieDetailViewController.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//

import UIKit

class MovieDetailViewController: UIViewController, ErrorHandlingDelegate  {
    
    var viewModel: MovieDetailViewModelProtocol!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var homepageLabel: UILabel!
    @IBOutlet weak var originalLanguageLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.errorDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesDidChange), name: Notification.Name("ValueDidChangeNotification"), object: nil)
        fetchMovieDetails()
    }
    
    @objc func favoritesDidChange() {
        fetchMovieDetails()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ValueDidChangeNotification"), object: nil)
    }
    
    internal func fetchMovieDetails(){
        // Fetch the list of now playing movies
        // The [weak self] is used to avoid a strong reference cycle (retain cycle)
        // and ensure that self (the view controller) can be deallocated when it's no longer needed.
        viewModel.fetchMovieDetails { [weak self] result in
            switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.updateMovieDetailUI()
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateMovieDetailUI() {
        titleLabel.text = viewModel.movie.title
        releaseDateLabel.text = viewModel.movie.releaseDate
        
        homepageLabel.text = viewModel.movieDetail?.homepage
        originalLanguageLabel.text = viewModel.movieDetail?.originalLanguage
        overviewTextView.text = viewModel.movieDetail?.overview
        updateFavoriteButtonUI()
    }
    
    private func updateFavoriteButtonUI() {
        favoriteButton.isHidden = false
        if viewModel.isFavorite {
            favoriteButton.setTitle("Remove from Favorites", for: .normal)
        } else {
            favoriteButton.setTitle("Add to Favorites", for: .normal)
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        if (viewModel.isFavorite && ((sender.titleLabel?.text?.contains("Add")) != nil)) || (!viewModel.isFavorite && ((sender.titleLabel?.text?.contains("Remove")) != nil)){
            
            NotificationCenter.default.post(name: Notification.Name("ValueDidChangeNotification"), object: nil, userInfo: ["FavoritesChanged": true])
        }
        
        viewModel.toggleFavoriteStatus()
        
        updateFavoriteButtonUI()
    }
}
