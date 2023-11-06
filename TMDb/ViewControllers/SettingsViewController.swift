//
//  SettingsViewController.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-11-04.
//

import UIKit

class SettingsViewController: UIViewController {
    var viewModel: SettingsViewModelProtocol!
    
    @IBOutlet private var sortSegmentedControl: UISegmentedControl!
    @IBOutlet private var filterSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Set up UI elements based on the viewModel's settings
        sortSegmentedControl.selectedSegmentIndex = viewModel.sortOption.rawValue
        filterSegmentedControl.selectedSegmentIndex = viewModel.filterOption.rawValue
    }
    
    @IBAction func sortOptionChanged(_ sender: UISegmentedControl) {
        if let sortOption = SortOption(rawValue: sender.selectedSegmentIndex) {
            viewModel.sortOption = sortOption
            viewModel.saveSettings() // Save settings when the sort option is changed
        }
    }
    
    @IBAction func filterOptionChanged(_ sender: UISegmentedControl) {
        if let filterOption = FilterOption(rawValue: sender.selectedSegmentIndex) {
            viewModel.filterOption = filterOption
            viewModel.saveSettings() // Save settings when the filter option is changed
        }
    }
}
