//
//  Constants.swift
//  YourAdventure
//
//  Created by Dominik Leszczyński on 19/04/2021.
//

import Foundation

struct Constants {
    
    //MARK: - Segues
    static let resultsParentSegue = "showResultsParentSegue"
    static let resultsSegue = "showResultsSegue"
    static let historyMapSegue = "showHistoryMapSegue"
    
    //MARK: - Units
    static let distanceUnit = "m"
    static let seconds = "s"
    
    //MARK: - Labels
    struct Labels {
        static let distanceText = "Distance:"
        static let infoText = "Press Start To Begin Your Next Adventure"
        static let resultsText = "Your Results"
        static let historyText = "Previous Adventures:"
        static let historyMapText = "History"
        static let barChartText = "Previous adventures distance"
        static let emptyStatsText = "Begin your first adventure to show stats here."
    }
    
    //MARK: - Cells
    static let themesCellIndentifier = "themeCell"
    static let historyCellIndetifier = "historyCell"
    
    //MARK: - Colors
    struct Colors {
        static let themeName = "Theme"
        static let share = "shareColor"
        static let defaultColor = "defaultPinkThemeColor"
        static let names = ["pink": "defaultPinkThemeColor",
                            "winter": "winterThemeColor",
                            "spring": "springThemeColor",
                            "summer": "summerThemeColor",
                            "autumn": "autumnThemeColor",
                            "aqua": "aquaThemeColor"]
        static let count: Int = {
            return names.keys.count
        }()
        static let array: [String] = {
            var colorArray: [String] = []
            for color in names.keys {
                colorArray.append(color)
            }
            return colorArray
        }()
    }
    
    //MARK: - Permissions
    struct PermissionsWarning {
        static let title = "No permission"
        static let message = "In order to work, app needs your location"
        static let openSettings = "Open settings"
        static let cancel = "Cancel"
    }
    //MARK: - UserDefaults
    struct UserDefaults {
        static let color = "TintColor"
        static let units = "Units"
        
        static let meters = "Metric"
        static let imperial = "Imperial"
    }

}
