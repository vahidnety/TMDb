//
//  MovieTableCell.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//

import Foundation
import UIKit
import SkeletonView

class MovieTableCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // Function to start the activity indicator
    func startLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    // Function to stop the activity indicator
    func stopLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func configure(with movie: Movie, image: UIImage? = nil) {
        self.activityIndicator.hidesWhenStopped = true
        titleLabel.text = movie.title
        releaseDateLabel.text = "Release Date: \(movie.releaseDate)"
        summaryLabel.text = movie.overview
        
        if let image = image {
            posterImageView.image = image
        }
        else {
            // Set a placeholder image while loading
            posterImageView.image = UIImage(named: "placeholderImage")
        }
    }
}
