//
//  FCMService.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Handles FCM token management and notification-related Firestore updates
final class FCMService {
    static let shared = FCMService()
    private init() {}

    private let db = Firestore.firestore()

    /// Update the FCM token in the user's Firestore document
    func updateToken(_ token: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            try await db.collection(FirestoreKeys.Collections.users).document(uid).updateData([
                FirestoreKeys.UserFields.fcmToken: token
            ])
        } catch {
            print("Failed to update FCM token: \(error.localizedDescription)")
        }
    }

    /// Fetch a user's FCM token for sending push notifications
    func fetchToken(forUserId userId: String) async -> String? {
        do {
            let doc = try await db.collection(FirestoreKeys.Collections.users).document(userId).getDocument()
            return doc.data()?[FirestoreKeys.UserFields.fcmToken] as? String
        } catch {
            return nil
        }
    }
}
