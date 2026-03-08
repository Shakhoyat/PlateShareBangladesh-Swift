//
//  ListingDetailView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct ListingDetailView: View {
    let listing: FoodListing
    let currentUserId: String?
    @State private var isShowingChat = false
    @State private var conversation: PSConversation?
    @State private var isLoadingChat = false
    @Environment(\.\.dismiss) private var dismiss

    var isOwnListing: Bool {
        currentUserId == listing.donorId
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Photo Gallery
                TabView {
                    if listing.imageURLs.isEmpty {
                        foodPlaceholder
                    } else {
                        ForEach(listing.imageURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        foodPlaceholder
                                    case .empty:
                                        ZStack {
                                            Color(.systemGray6)
                                            ProgressView()
                                        }
                                    @unknown default:
                                        foodPlaceholder
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 280)
                .tabViewStyle(.page)

                VStack(alignment: .leading, spacing: 16) {
                    // Title & Category
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(listing.title)
                                .font(.title2.bold())
                                .foregroundColor(.psTextPrimary)

                            HStack(spacing: 4) {
                                Text(listing.category.emoji)
                                Text(listing.category.rawValue.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.psTextSecondary)
                            }
                        }
                        Spacer()

                        if !listing.isAvailable {
                            PSBadgeView(text: "Taken", color: .psError, icon: "xmark.circle.fill")
                        }
                    }

                    // Tags row
                    HStack(spacing: 8) {
                        if listing.isHalal {
                            PSBadgeView(text: "Halal", color: .psGreen, icon: "checkmark.circle.fill")
                        }
                        PSBadgeView(text: listing.quantity, color: .psOrange, icon: "person.2.fill")
                        PSBadgeView(
                            text: listing.expiresAt.isExpired ? "Expired" : "Expires \(listing.expiresAt.timeAgo)",
                            color: listing.expiresAt.isExpired ? .psError : .psWarning,
                            icon: "clock"
                        )
                    }

                    Divider()

                    // Description
                    if let description = listing.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.psTextPrimary)
                            Text(description)
                                .font(.body)
                                .foregroundColor(.psTextSecondary)
                        }
                    }

                    // Donor section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Shared by")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.psTextPrimary)

                        HStack(spacing: 12) {
                            PSAvatarView(imageURL: nil, size: 44, showBadge: true)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(listing.donorName)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.psTextPrimary)
                                Text("Verified Donor")
                                    .font(.caption)
                                    .foregroundColor(.psGreen)
                            }

                            Spacer()
                        }
                    }

                    Divider()

                    // Pickup Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pickup Location")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.psTextPrimary)

                        HStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.psOrange)
                            Text(listing.pickupAddress)
                                .font(.body)
                                .foregroundColor(.psTextSecondary)
                        }
                    }

                    // Post Date
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .foregroundColor(.psTextSecondary)
                        Text("Posted \(listing.createdAt.timeAgo)")
                            .font(.caption)
                            .foregroundColor(.psTextSecondary)
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if !isOwnListing && listing.isAvailable {
                // Message Donor button
                PSButton(
                    "Message Donor 💬",
                    isLoading: isLoadingChat
                ) {
                    Task { await startChat() }
                }
                .accessibilityLabel("Message \(listing.donorName)")
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
        .sheet(isPresented: $isShowingChat) {
            if let conversation = conversation {
                NavigationStack {
                    ChatView(conversation: conversation, otherUserName: listing.donorName)
                }
            }
        }
    }

    private var foodPlaceholder: some View {
        ZStack {
            Color(.systemGray5)
            VStack(spacing: 8) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 40))
                    .foregroundColor(.psTextSecondary.opacity(0.3))
                Text("No photo available")
                    .font(.caption)
                    .foregroundColor(.psTextSecondary.opacity(0.5))
            }
        }
    }

    private func startChat() async {
        guard let currentUID = currentUserId else { return }
        isLoadingChat = true

        do {
            let conv = try await FirestoreService.shared.getOrCreateConversation(
                listingId: listing.id,
                donorId: listing.donorId,
                recipientId: currentUID
            )
            self.conversation = conv
            self.isShowingChat = true
        } catch {
            // Handle error silently for now
        }
        isLoadingChat = false
    }
}

#Preview {
    NavigationStack {
        ListingDetailView(listing: FoodListing(
            id: "1",
            donorId: "u1",
            donorName: "Rahim Uncle",
            title: "Wedding Biryani - Fresh & Hot",
            description: "Leftover biryani from a wonderful wedding reception. Still fresh and warm. Come pick it up before 8 PM.",
            category: .biryani,
            quantity: "Serves 20",
            imageURLs: [],
            pickupAddress: "Dhanmondi 27, Block A, Road 4",
            latitude: 23.8103,
            longitude: 90.4125,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date.hoursFromNow(3),
            createdAt: Date()
        ), currentUserId: "preview-user")
    }
}
