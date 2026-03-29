//
//  ChatView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    let otherUserName: String
    @FocusState private var isInputFocused: Bool

    init(conversation: PSConversation, otherUserName: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(conversationId: conversation.id))
        self.otherUserName = otherUserName
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(
                                message: message,
                                isFromCurrentUser: message.senderId == viewModel.currentUID
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: viewModel.messages.count) { _, _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Message Input Bar
            HStack(spacing: 12) {
                TextField("Type a message...", text: $viewModel.messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .focused($isInputFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        sendWithHaptic()
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Button {
                    sendWithHaptic()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color(.systemGray3)
                            : Color.psAccent
                        )
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: viewModel.messageText.isEmpty)
                }
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
        .navigationTitle(otherUserName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func sendWithHaptic() {
        guard !viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        PSHaptics.light()
        Task { await viewModel.sendMessage() }
    }
}

#Preview {
    NavigationStack {
        ChatView(
            conversation: PSConversation(
                id: "test",
                listingId: "l1",
                participantIds: ["u1", "u2"],
                lastMessage: "Hello!",
                lastMessageAt: Date(),
                unreadCount: 0
            ),
            otherUserName: "Rahim Uncle"
        )
    }
}
