//
//  AppConstants.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation

enum AppConstants {
    enum Location {
        static let defaultLatitude = 23.8103   // Dhaka, Bangladesh
        static let defaultLongitude = 90.4125
        static let defaultRadiusKM: Double = 2.0
        static let minRadiusKM: Double = 0.5
        static let maxRadiusKM: Double = 5.0
    }

    enum Listing {
        static let maxTitleLength = 100
        static let maxDescriptionLength = 500
        static let maxPhotoCount = 3
        static let maxImageSizeKB = 500
        static let defaultExpiryHours = 6
    }

    enum Pagination {
        static let pageSize = 20
    }

    enum Languages {
        static let english = "en"
        static let bangla = "bn"
    }

    enum UserDefaultsKeys {
        static let preferredLanguageKey = "preferredLanguage"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
}
