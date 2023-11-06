//
//  UIViewController+Alert.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-31.
//

import Foundation
import UIKit

protocol ErrorHandlingDelegate: AnyObject {
    func viewModelDidFail(with error: AppError)
}

extension UIViewController {
    func viewModelDidFail(with error: AppError) {
        // Handle and display error alerts
        switch error {
            case .networkError:
                showAlert(title: "Network Error", message: "Please check your internet connection.")
            case .parsingError:
                showAlert(title: "Parsing Error", message: "Failed to parse data.")
            case .dataNotFound:
                showAlert(title: "Data Not Found", message: "No data available.")
            case .other(let message):
                showAlert(title: "Error", message: message)
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
