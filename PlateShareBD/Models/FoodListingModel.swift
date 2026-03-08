//
//  FoodListingModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation

struct FoodListing: Codable, Identifiable, Hashable {
    let id: String
    let donorId: String
    var donorName: String
    var title: String
    var description: String?
    var category: FoodCategory
    var quantity: String              // "Serves 10 people"
    var imageURLs: [String]
    var pickupAddress: String
    var latitude: Double
    var longitude: Double
    var isHalal: Bool
    var isAvailable: Bool
    var expiresAt: Date
    var createdAt: Date

    enum FoodCategory: String, Codable, CaseIterable {
        case biryani = "biryani"
        case rice = "rice"
        case curry = "curry"
        case fish = "fish"
        case sweets = "sweets"
        case iftar = "iftar"
        case fruits = "fruits"
        case bakery = "bakery"
        case other = "other"

        var banglaName: String {
            switch self {
            case .biryani: return "বিরিয়ানি"
            case .rice: return "ভাত"
            case .curry: return "তরকারি"
            case .fish: return "মাছ"
            case .sweets: return "মিষ্টি"
            case .iftar: return "ইফতার"
            case .fruits: return "ফল"
            case .bakery: return "বেকারি"
            case .other: return "অন্যান্য"
            }
        }

        var emoji: String {
            switch self {
            case .biryani: return "🍛"
            case .rice: return "🍚"
            case .curry: return "🥘"
            case .fish: return "🐟"
            case .sweets: return "🍮"
            case .iftar: return "🌙"
            case .fruits: return "🍎"
            case .bakery: return "🍞"
            case .other: return "🍽️"
            }
        }
    }

    // Hashable conformance using id
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FoodListing, rhs: FoodListing) -> Bool {
        lhs.id == rhs.id
    }
}
