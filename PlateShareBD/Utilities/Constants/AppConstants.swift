//
//  AppConstants.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import MapKit

enum AppConstants {
    enum Location {
        // KUET, Khulna — single source of truth for default map center
        static let kuetLatitude: CLLocationDegrees = 22.8998
        static let kuetLongitude: CLLocationDegrees = 89.5022
        static let kuetRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 22.8998, longitude: 89.5022),
            latitudinalMeters: 3000, longitudinalMeters: 3000
        )
        // Legacy aliases — point to the same KUET values
        static let defaultLatitude = kuetLatitude
        static let defaultLongitude = kuetLongitude
        // Geographic center of Bangladesh — used for country-wide MKLocalSearch bias
        static let bangladeshCenterLatitude = 23.6850
        static let bangladeshCenterLongitude = 90.3563
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

    // MARK: - Cloudinary (free image hosting — replaces Firebase Storage)
    // 1. Sign up at https://cloudinary.com (free, no credit card)
    // 2. Dashboard → Settings → Upload → Add upload preset → set to "Unsigned"
    // 3. Paste your Cloud Name and the preset name below
    enum Cloudinary {
        static let cloudName   = "dkim6e0jo"
        static let uploadPreset = "plateshare-bd"

        #if DEBUG
        static func validate() {
            assert(
                cloudName != "plateshare-bd-placeholder" &&
                !cloudName.isEmpty,
                "❌ Cloudinary cloudName not configured"
            )
        }
        #endif
    }

    enum Languages {
        static let english = "en"
        static let bangla = "bn"
    }

    enum UserDefaultsKeys {
        static let preferredLanguageKey = "preferredLanguage"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let hasSeededDemoData = "hasSeededDemoData_v1"
    }
}
