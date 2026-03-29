//
//  FirestoreKeys.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation

enum FirestoreKeys {
    enum Collections {
        static let users = "users"
        static let listings = "listings"
        static let conversations = "conversations"
        static let messages = "messages"
        static let ratings = "ratings"
    }

    enum UserFields {
        static let id = "id"
        static let displayName = "displayName"
        static let email = "email"
        static let area = "area"
        static let profileImageURL = "profileImageURL"
        static let isVerified = "isVerified"
        static let donorRating = "donorRating"
        static let fcmToken = "fcmToken"
        static let preferredLanguage = "preferredLanguage"
        static let createdAt = "createdAt"
    }

    enum ListingFields {
        static let donorId = "donorId"
        static let isAvailable = "isAvailable"
        static let expiresAt = "expiresAt"
        static let createdAt = "createdAt"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let category = "category"
    }

    enum MessageFields {
        static let senderId = "senderId"
        static let conversationId = "conversationId"
        static let isRead = "isRead"
        static let createdAt = "createdAt"
    }

    enum ConversationFields {
        static let listingId = "listingId"
        static let participantIds = "participantIds"
        static let lastMessage = "lastMessage"
        static let lastMessageAt = "lastMessageAt"
        static let unreadCount = "unreadCount"
    }
}
