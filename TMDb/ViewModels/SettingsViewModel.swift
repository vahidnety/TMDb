//
//  SettingsViewModel.swift
//  TMDb
//
//  Created by Seyedvahid Dianat on 2023-11-04.
//

import Foundation

//protocol SettingsViewModelDelegate: AnyObject {
//    func settingsUpdated(settings: [String: Int])
//}

enum SortOption: Int {
    case DefaultSort, Popularity, Revenue
    var description: String {
        switch self {
            case .DefaultSort:
                return "defaultSort"
            case .Popularity:
                return "popularity"
            case .Revenue:
                return "revenue"
        }
    }
}
enum FilterOption: Int {
    case DefaultFilter, Year2024, Year2023, Year2022
    var description: String {
        switch self {
            case .DefaultFilter:
                return "defaultFilter"
            case .Year2024:
                return "2024"
            case .Year2023:
                return "2023"
            case .Year2022:
                return "2022"
        }
    }
}

protocol SettingsViewModelProtocol {
//    var delegate: SettingsViewModelDelegate? { get set }
    var sortOption: SortOption { get set }
    var filterOption: FilterOption { get set }
    func saveSettings()
}

class SettingsViewModel: SettingsViewModelProtocol {
//    weak var delegate: SettingsViewModelDelegate?
    var sortOption: SortOption = .DefaultSort {
        didSet {
            saveSettings()
        }
    }
    var filterOption: FilterOption = .DefaultFilter {
        didSet {
            saveSettings()
        }
    }
    
    func saveSettings() {
        // Save settings to user defaults or another persistent storage
//        self.delegate?.settingsUpdated(settings: ["Sort":sortOption.rawValue ,"Filter":filterOption.rawValue])
    }
}
