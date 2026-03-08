//
//  ConversationListViewModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class ConversationListViewModel: ObservableObject {
    @Published var conversations: [PSConversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Cache user names for display
    @Published var userNames: [String: String] = [:]

    private var listener: ListenerRegistration?
    private let firestoreService = FirestoreService.shared

    init() {
        startListening()
    }

    func startListening() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }

        listener?.remove()

        let db = Firestore.firestore()
        listener = db.collection(FirestoreKeys.Collections.conversations)
            .whereField(FirestoreKeys.ConversationFields.participantIds, arrayContains: currentUID)
            .order(by: FirestoreKeys.ConversationFields.lastMessageAt, descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else { return }
                Task { @MainActor in
                    self.conversations = documents.compactMap { try? $0.data(as: PSConversation.self) }
                    await self.loadUserNames()
                }
            }
    }

    // Load display names for the other participant in each conversation
    private func loadUserNames() async {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }

        for conversation in conversations {
            let otherUserId = conversation.participantIds.first { $0 != currentUID } ?? ""
            if userNames[otherUserId] == nil {
                if let user = try? await firestoreService.fetchUser(uid: otherUserId) {
                    userNames[otherUserId] = user.displayName
                }
            }
        }
    }

    func getOtherUserName(for conversation: PSConversation) -> String {
        guard let currentUID = Auth.auth().currentUser?.uid else { return "User" }
        let otherUserId = conversation.participantIds.first { $0 != currentUID } ?? ""
        return userNames[otherUserId] ?? "User"
    }

    deinit {
        listener?.remove()
    }
}
