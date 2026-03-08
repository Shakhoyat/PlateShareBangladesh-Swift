//
//  ChatViewModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [PSMessage] = []
    @Published var messageText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    let conversationId: String
    private var messagesListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    private let firestoreService = FirestoreService.shared
    private let messagingService = MessagingService.shared

    var currentUID: String? {
        Auth.auth().currentUser?.uid
    }

    init(conversationId: String) {
        self.conversationId = conversationId
        startListening()
    }

    func startListening() {
        messagesListener?.remove()

        let db = Firestore.firestore()
        messagesListener = db.collection(FirestoreKeys.Collections.conversations)
            .document(conversationId)
            .collection(FirestoreKeys.Collections.messages)
            .order(by: FirestoreKeys.MessageFields.createdAt)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else { return }
                Task { @MainActor in
                    self.messages = documents.compactMap { try? $0.data(as: PSMessage.self) }
                }
            }

        // Mark messages as read
        Task {
            try? await messagingService.markMessagesRead(conversationId: conversationId)
        }
    }

    func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messageText = ""

        do {
            try await firestoreService.sendMessage(conversationId: conversationId, text: text)
        } catch {
            errorMessage = "Failed to send message."
            messageText = text // Restore text on failure
        }
    }

    deinit {
        messagesListener?.remove()
    }
}
