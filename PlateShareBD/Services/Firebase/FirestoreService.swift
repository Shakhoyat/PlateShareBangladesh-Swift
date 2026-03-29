//
//  FirestoreService.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum AppError: LocalizedError {
    case notAuthenticated
    case permissionDenied
    case documentNotFound
    case encodingError
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "You must be logged in."
        case .permissionDenied: return "You don't have permission for this action."
        case .documentNotFound: return "The requested content was not found."
        case .encodingError: return "Data processing error. Please try again."
        case .networkError: return "Network error. Check your internet connection."
        case .unknown(let msg): return msg
        }
    }
}

final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}

    private let db = Firestore.firestore()

    // ─── LISTINGS ────────────────────────────────────────────

    // Create a new listing
    func createListing(_ listing: FoodListing) async throws {
        guard Auth.auth().currentUser != nil else { throw AppError.notAuthenticated }

        let data: [String: Any]
        do {
            data = try Firestore.Encoder().encode(listing)
        } catch {
            throw AppError.encodingError
        }
        try await db.collection(FirestoreKeys.Collections.listings).document(listing.id).setData(data)
    }

    // Fetch listings for the feed (single-field query — no composite index needed)
    func fetchListings(
        limit: Int = 50
    ) async throws -> [FoodListing] {
        let query: Query = db.collection(FirestoreKeys.Collections.listings)
            .order(by: FirestoreKeys.ListingFields.createdAt, descending: true)
            .limit(to: limit)

        let snapshot = try await query.getDocuments()
        let now = Date()
        return snapshot.documents
            .compactMap { try? $0.data(as: FoodListing.self) }
            .filter { $0.isAvailable && $0.expiresAt > now }
    }

// Mark listing as taken
    func markListingTaken(listingId: String) async throws {
        try await db.collection(FirestoreKeys.Collections.listings).document(listingId)
            .updateData([FirestoreKeys.ListingFields.isAvailable: false])
    }

    // Fetch listings for a specific donor (single-field query — no composite index needed)
    func fetchUserListings(donorId: String) async throws -> [FoodListing] {
        let snapshot = try await db.collection(FirestoreKeys.Collections.listings)
            .whereField(FirestoreKeys.ListingFields.donorId, isEqualTo: donorId)
            .getDocuments()
        return snapshot.documents
            .compactMap { try? $0.data(as: FoodListing.self) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    // Delete a listing
    func deleteListing(listingId: String) async throws {
        try await db.collection(FirestoreKeys.Collections.listings).document(listingId).delete()
    }

    // ─── MESSAGING ────────────────────────────────────────────

    // Get or create a conversation
    func getOrCreateConversation(
        listingId: String,
        donorId: String,
        recipientId: String
    ) async throws -> PSConversation {
        // Check if conversation already exists
        let existing = try await db.collection(FirestoreKeys.Collections.conversations)
            .whereField(FirestoreKeys.ConversationFields.listingId, isEqualTo: listingId)
            .whereField(FirestoreKeys.ConversationFields.participantIds, arrayContains: recipientId)
            .getDocuments()

        if let doc = existing.documents.first,
           let conversation = try? doc.data(as: PSConversation.self) {
            return conversation
        }

        // Create new conversation
        let conversationId = db.collection(FirestoreKeys.Collections.conversations).document().documentID
        let conversation = PSConversation(
            id: conversationId,
            listingId: listingId,
            participantIds: [donorId, recipientId],
            lastMessage: nil,
            lastMessageAt: nil,
            unreadCount: 0
        )

        let data = try Firestore.Encoder().encode(conversation)
        try await db.collection(FirestoreKeys.Collections.conversations).document(conversationId).setData(data)
        return conversation
    }

    // Send a message
    func sendMessage(
        conversationId: String,
        text: String
    ) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            throw AppError.notAuthenticated
        }

        let messageId = db.collection(FirestoreKeys.Collections.conversations)
            .document(conversationId)
            .collection(FirestoreKeys.Collections.messages)
            .document().documentID

        let message = PSMessage(
            id: messageId,
            senderId: currentUID,
            conversationId: conversationId,
            text: text,
            audioURL: nil,
            isRead: false,
            createdAt: Date()
        )

        let messageData = try Firestore.Encoder().encode(message)

        // Batch write: add message + update conversation's lastMessage
        let batch = db.batch()
        let messageRef = db.collection(FirestoreKeys.Collections.conversations)
            .document(conversationId)
            .collection(FirestoreKeys.Collections.messages)
            .document(messageId)
        batch.setData(messageData, forDocument: messageRef)

        let conversationRef = db.collection(FirestoreKeys.Collections.conversations).document(conversationId)
        batch.updateData([
            FirestoreKeys.ConversationFields.lastMessage: text,
            FirestoreKeys.ConversationFields.lastMessageAt: Timestamp(date: Date()),
            FirestoreKeys.ConversationFields.unreadCount: FieldValue.increment(Int64(1))
        ], forDocument: conversationRef)

        try await batch.commit()
    }

// Fetch user conversations (single-field query — no composite index needed)
    func fetchConversations(userId: String) async throws -> [PSConversation] {
        let snapshot = try await db.collection(FirestoreKeys.Collections.conversations)
            .whereField(FirestoreKeys.ConversationFields.participantIds, arrayContains: userId)
            .getDocuments()
        return snapshot.documents
            .compactMap { try? $0.data(as: PSConversation.self) }
            .sorted { ($0.lastMessageAt ?? .distantPast) > ($1.lastMessageAt ?? .distantPast) }
    }

    // ─── USERS ────────────────────────────────────────────────

    func fetchUser(uid: String) async throws -> PSUser {
        let doc = try await db.collection(FirestoreKeys.Collections.users).document(uid).getDocument()
        guard let user = try? doc.data(as: PSUser.self) else {
            throw AppError.documentNotFound
        }
        return user
    }

    func updateUser(uid: String, data: [String: Any]) async throws {
        try await db.collection(FirestoreKeys.Collections.users).document(uid).updateData(data)
    }

    // ─── RATINGS ──────────────────────────────────────────────

    func submitRating(_ rating: PSRating) async throws {
        let data = try Firestore.Encoder().encode(rating)
        let ratingRef = db.collection(FirestoreKeys.Collections.ratings).document()
        try await ratingRef.setData(data)

        // Update donor's average rating
        let snapshot = try await db.collection(FirestoreKeys.Collections.ratings)
            .whereField("toUserId", isEqualTo: rating.toUserId)
            .getDocuments()

        let scores = snapshot.documents.compactMap { try? $0.data(as: PSRating.self) }.map(\.score)
        guard !scores.isEmpty else { return }
        let avg = Double(scores.reduce(0, +)) / Double(scores.count)
        try await db.collection(FirestoreKeys.Collections.users).document(rating.toUserId)
            .updateData([FirestoreKeys.UserFields.donorRating: avg])
    }
}
