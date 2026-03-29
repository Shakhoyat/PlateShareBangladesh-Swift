//
//  MessagingService.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Dedicated service for messaging operations that wraps FirestoreService
/// messaging methods and adds additional messaging-specific logic.
final class MessagingService {
    static let shared = MessagingService()
    private init() {}

    private let firestoreService = FirestoreService.shared
    private let db = Firestore.firestore()

    // Start or resume a conversation about a specific listing
    func startConversation(
        listingId: String,
        donorId: String
    ) async throws -> PSConversation {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            throw AppError.notAuthenticated
        }

        return try await firestoreService.getOrCreateConversation(
            listingId: listingId,
            donorId: donorId,
            recipientId: currentUID
        )
    }

    // Send a text message in a conversation
    func sendMessage(conversationId: String, text: String) async throws {
        try await firestoreService.sendMessage(conversationId: conversationId, text: text)
    }

    // Mark messages as read
    func markMessagesRead(conversationId: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }

        let messagesRef = db.collection(FirestoreKeys.Collections.conversations)
            .document(conversationId)
            .collection(FirestoreKeys.Collections.messages)
            .whereField(FirestoreKeys.MessageFields.senderId, isNotEqualTo: currentUID)
            .whereField(FirestoreKeys.MessageFields.isRead, isEqualTo: false)

        let snapshot = try await messagesRef.getDocuments()

        let batch = db.batch()
        for doc in snapshot.documents {
            batch.updateData([FirestoreKeys.MessageFields.isRead: true], forDocument: doc.reference)
        }

        // Reset unread count on conversation
        let conversationRef = db.collection(FirestoreKeys.Collections.conversations).document(conversationId)
        batch.updateData([FirestoreKeys.ConversationFields.unreadCount: 0], forDocument: conversationRef)

        try await batch.commit()
    }
}
