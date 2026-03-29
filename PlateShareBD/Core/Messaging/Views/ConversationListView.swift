//
//  ConversationListView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct ConversationListView: View {
    @StateObject private var viewModel = ConversationListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.conversations.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    List(viewModel.conversations) { conversation in
                        NavigationLink(destination: ChatView(
                            conversation: conversation,
                            otherUserName: viewModel.getOtherUserName(for: conversation)
                        )) {
                            ConversationRowView(
                                conversation: conversation,
                                otherUserName: viewModel.getOtherUserName(for: conversation)
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("messages.title")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 50))
                .foregroundStyle(Color.psTextSecondary.opacity(0.4))

            Text("messages.empty.title")
                .font(.headline)
                .foregroundStyle(Color.psTextPrimary)

            Text("messages.empty.subtitle")
                .font(.subheadline)
                .foregroundStyle(Color.psTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

struct ConversationRowView: View {
    let conversation: PSConversation
    let otherUserName: String

    var body: some View {
        HStack(spacing: 12) {
            PSAvatarView(imageURL: nil, size: 50)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherUserName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.psTextPrimary)

                    Spacer()

                    if let date = conversation.lastMessageAt {
                        Text(date.timeAgo)
                            .font(.caption2)
                            .foregroundStyle(Color.psTextSecondary)
                    }
                }

                HStack {
                    Text(conversation.lastMessage ?? "No messages yet")
                        .font(.caption)
                        .foregroundStyle(Color.psTextSecondary)
                        .lineLimit(1)

                    Spacer()

                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.white)
                            .frame(width: 20, height: 20)
                            .background(Color.psAccent)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ConversationListView()
}
