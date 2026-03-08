//
//  RatingModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseFirestore

struct PSRating: Codable, Identifiable {
    @DocumentID var id: String?
    var fromUserId: String
    var toUserId: String
    var listingId: String
    var score: Int                     // 1–5
    var comment: String?
    var createdAt: Date
}
