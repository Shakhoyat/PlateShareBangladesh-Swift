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
                .onChange(of: viewModel.messages.count) { _, _ in
                    withAnimation {
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
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Button {
                    Task { await viewModel.sendMessage() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color(.systemGray3)
                            : Color.psAccent
                        )
                }
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
        .navigationTitle(otherUserName)
        .navigationBarTitleDisplayMode(.inline)
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
