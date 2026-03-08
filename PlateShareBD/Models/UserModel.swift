//
//  UserModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation

struct PSUser: Codable, Identifiable {
    let id: String                    // Firebase UID
    var displayName: String
    var email: String
    var area: String                  // mohalla/para
    var profileImageURL: String?
    var isVerified: Bool
    var donorRating: Double           // 0.0 - 5.0
    var totalDonations: Int
    var fcmToken: String?
    var preferredLanguage: String     // "en" or "bn"
    var createdAt: Date
}
