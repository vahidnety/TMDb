//
//  MovieDetailViewController.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//

import UIKit
import YoutubePlayer

class MovieDetailViewController: UIViewController, ErrorHandlingDelegate, YoutubePlayerDelegate  {
    func youtubePlayer(_ videoPlayer: YoutubePlayer.YoutubePlayerView, fired event: YoutubePlayer.YoutubePlayerEvent) {
        print("youtubePlayer=\(event)")
    }
    
    
    var viewModel: MovieDetailViewModelProtocol!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var homepageLabel: UILabel!
    @IBOutlet weak var originalLanguageLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var playerView: YoutubePlayerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.errorDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesDidChange), name: Notification.Name("ValueDidChangeNotification"), object: nil)
        fetchMovieDetails()
        fetchTrailers()
        bindViewModel()
    }
    
    @objc func favoritesDidChange() {
        fetchMovieDetails()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ValueDidChangeNotification"), object: nil)
    }
    // You need to implement a method or property observer in the view controller to update the UI when trailers are fetched in the view model.
    // For example, if using a closure to update UI:
    
    // Updating the UI after trailers are fetched
    func bindViewModel() {
        viewModel.onTrailersUpdate = { [weak self] trailers in
            self?.updateUIWith(trailers)
        }
    }
    
    // Method to update UI with fetched trailers
    func updateUIWith(_ trailers: [MovieTrailer]) {
        // Update your UI here with the fetched trailers
        //        print("trailers:\(trailers)")
        if let viewModel = viewModel {
            self.playerView.delegate = self
            
            // Set up the player with the video ID from the ViewModel.
            DispatchQueue.main.async {
                // Load video from YouTube ID
                try? self.playerView.loadVideo(withId: viewModel.videoID ?? "", playerVars: YoutubePlayerOptions.Parameters(playsInline: .true))
            }
        }
    }
    
    internal func fetchTrailers() {
        viewModel.fetchTrailers()
    }
    
    internal func fetchMovieDetails() {
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
