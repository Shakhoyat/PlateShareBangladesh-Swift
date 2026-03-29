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
    @State private var isShowingRating = false
    @State private var conversation: PSConversation?
    @State private var isLoadingChat = false
    @State private var chatError: String?
    @Environment(\.dismiss) private var dismiss

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
                                .foregroundStyle(Color.psTextPrimary)

                            HStack(spacing: 4) {
                                Image(systemName: listing.category.sfSymbol)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.psAccent)
                                Text(listing.category.rawValue.capitalized)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.psTextSecondary)
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
                            PSBadgeView(text: "Halal", color: .psAccent, icon: "checkmark.circle.fill")
                        }
                        PSBadgeView(text: listing.quantity, color: .psSecondary, icon: "person.2.fill")
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
                                .foregroundStyle(Color.psTextPrimary)
                            Text(description)
                                .font(.body)
                                .foregroundStyle(Color.psTextSecondary)
                        }
                    }

                    // Donor section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Shared by")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.psTextPrimary)

                        HStack(spacing: 12) {
                            PSAvatarView(imageURL: nil, size: 44, showBadge: true)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(listing.donorName)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color.psTextPrimary)
                                Text("Verified Donor")
                                    .font(.caption)
                                    .foregroundStyle(Color.psAccent)
                            }

                            Spacer()
                        }
                    }

                    Divider()

                    // Pickup Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pickup Location")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.psTextPrimary)

                        HStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(Color.psSecondary)
                            Text(listing.pickupAddress)
                                .font(.body)
                                .foregroundStyle(Color.psTextSecondary)
                        }
                    }

                    // Post Date
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color.psTextSecondary)
                        Text("Posted \(listing.createdAt.timeAgo)")
                            .font(.caption)
                            .foregroundStyle(Color.psTextSecondary)
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(
                    item: "\(listing.title)\nShared by \(listing.donorName)\nPickup: \(listing.pickupAddress)",
                    subject: Text("Food available on PlateShare BD")
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isOwnListing && listing.isAvailable {
                VStack(spacing: 8) {
                    if let error = chatError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(Color.psError)
                            .multilineTextAlignment(.center)
                    }
                    PSButton(
                        "Message Donor",
                        isLoading: isLoadingChat
                    ) {
                        Task { await startChat() }
                    }
                    .accessibilityLabel("Message \(listing.donorName)")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            } else if !isOwnListing && !listing.isAvailable {
                // Rate Donor button (listing already taken)
                PSButton("Rate Donor") {
                    isShowingRating = true
                }
                .accessibilityLabel("Rate \(listing.donorName)")
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
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
            }
        }
        .sheet(isPresented: $isShowingRating) {
            if let uid = currentUserId {
                NavigationStack {
                    RatingView(
                        donorId: listing.donorId,
                        donorName: listing.donorName,
                        listingId: listing.id,
                        currentUserId: uid
                    )
                    .navigationTitle("Rate Donor")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
            }
        }
    }

    private var foodPlaceholder: some View {
        ZStack {
            Color(.systemGray5)
            VStack(spacing: 8) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.psTextSecondary.opacity(0.3))
                Text("No photo available")
                    .font(.caption)
                    .foregroundStyle(Color.psTextSecondary.opacity(0.5))
            }
        }
    }

    private func startChat() async {
        guard let currentUID = currentUserId else { return }
        isLoadingChat = true
        chatError = nil

        do {
            let conv = try await FirestoreService.shared.getOrCreateConversation(
                listingId: listing.id,
                donorId: listing.donorId,
                recipientId: currentUID
            )
            self.conversation = conv
            self.isShowingChat = true
        } catch {
            self.chatError = "Could not open chat. Please try again."
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
