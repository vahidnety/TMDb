//
//  UIViewController+Refresh.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-10-31.
//

import Foundation
import UIKit

extension UIViewController {
    // Add a refresh control to a UITableView with a custom action
    func addRefreshControl(to tableView: UITableView, action: Selector) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: action, for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // Manually start the refresh control
    func startRefreshing(for tableView: UITableView) {
        tableView.refreshControl?.beginRefreshing()
        let offsetPoint = CGPoint(x: 0, y: -tableView.refreshControl!.frame.height)
        tableView.setContentOffset(offsetPoint, animated: true)
    }
    
    // Manually stop the refresh control
    func stopRefreshing(for tableView: UITableView) {
        tableView.refreshControl?.endRefreshing()
    }
    
    // Customize the appearance and color of the refresh control
    func customizeRefreshControl(for tableView: UITableView, tintColor: UIColor, backgroundColor: UIColor) {
        tableView.refreshControl?.tintColor = tintColor
        tableView.refreshControl?.backgroundColor = backgroundColor
    }
}
