//
//  SettingsViewControllerTests.swift
//  TMDbTests
//
//  Created by Vahid on 07/11/2023.
//

import XCTest
@testable import TMDb // Import your app module

class SettingsViewControllerTests: XCTestCase {
    var viewController: SettingsViewController!
    var viewModel: MockSettingsViewModel!

    override func setUp() {
        super.setUp()

        // Create a mock SettingsViewModel for testing
        viewModel = MockSettingsViewModel()
        
        // Initialize the view controller with the mock viewModel
        viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
        viewController.viewModel = viewModel

        // Load the view
        viewController.loadView()
    }

    override func tearDown() {
        viewController = nil
        viewModel = nil
        super.tearDown()
    }

    // Test if the UI is set up correctly based on viewModel's settings
    func testUISetup() {
        // Verify if the segmented controls are set correctly based on the viewModel
        XCTAssertEqual(viewController.sortSegmentedControl.selectedSegmentIndex, viewModel.sortOption.rawValue)
        XCTAssertEqual(viewController.filterSegmentedControl.selectedSegmentIndex, viewModel.filterOption.rawValue)
    }

    // Test if changing the sort option updates the viewModel and saves settings
    func testSortOptionChanged() {
        // Simulate user changing the sort option
        viewController.sortOptionChanged(viewController.sortSegmentedControl)

        // Verify if the viewModel's sort option is updated
        XCTAssertEqual(viewModel.sortOption, .Popularity)

        // Verify if the saveSettings method is called in the viewModel
        XCTAssertTrue(viewModel.didSaveSettings)
    }

    // Test if changing the filter option updates the viewModel and saves settings
    func testFilterOptionChanged() {
        // Simulate user changing the filter option
        viewController.filterOptionChanged(viewController.filterSegmentedControl)

        // Verify if the viewModel's filter option is updated
        XCTAssertEqual(viewModel.filterOption, .Year2024)

        // Verify if the saveSettings method is called in the viewModel
        XCTAssertTrue(viewModel.didSaveSettings)
    }
}

class MockSettingsViewModel: SettingsViewModelProtocol {
    var sortOption: SortOption = .DefaultSort
    var filterOption: FilterOption = .DefaultFilter
    var didSaveSettings = false

    func saveSettings() {
        
        sortOption = SortOption(rawValue: 1) ?? .DefaultSort
        filterOption = FilterOption(rawValue: 1) ?? .DefaultFilter
        
        // Simulate saving settings
        didSaveSettings = true
    }
}

class SettingsViewModelTests: XCTestCase {
    // Write tests for the SettingsViewModel here
    // You can test setting and saving sort and filter options
    // as well as testing any other functionality provided by the viewModel.
}
