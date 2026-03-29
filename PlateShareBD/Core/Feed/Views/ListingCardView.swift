//
//  ListingCardView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct ListingCardView: View {
    let listing: FoodListing

    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topTrailing) {
                if let firstImageURL = listing.imageURLs.first,
                   let url = URL(string: firstImageURL) {
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
                    .frame(height: 180)
                    .clipped()
                } else {
                    foodPlaceholder
                        .frame(height: 180)
                }

                // Category badge
                HStack(spacing: 4) {
                    Image(systemName: listing.category.sfSymbol)
                        .font(.caption2)
                    Text(listing.category.rawValue.capitalized)
                        .font(.caption2.weight(.semibold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(8)
            }

            // Details
            VStack(alignment: .leading, spacing: 8) {
                Text(listing.title)
                    .font(.headline)
                    .foregroundStyle(Color.psTextPrimary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.psTextSecondary)
                    Text(listing.donorName)
                        .font(.caption)
                        .foregroundStyle(Color.psTextSecondary)
                }

                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.psSecondary)
                        Text(listing.pickupAddress.truncated(to: 25))
                            .font(.caption2)
                            .foregroundStyle(Color.psTextSecondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundStyle(listing.expiresAt.isExpired ? Color.psError : Color.psTextSecondary)
                        Text(listing.expiresAt.timeAgo)
                            .font(.caption2)
                            .foregroundStyle(listing.expiresAt.isExpired ? Color.psError : Color.psTextSecondary)
                    }
                }

                HStack(spacing: 6) {
                    if listing.isHalal {
                        PSBadgeView(text: "Halal", color: .psAccent, icon: "checkmark.circle.fill")
                    }
                    PSBadgeView(text: listing.quantity, color: .psSecondary, icon: "person.2.fill")
                }
            }
            .padding(12)
        }
        .background(Color.psBgCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: .black.opacity(isPressed ? 0.04 : 0.08),
            radius: isPressed ? 4 : 10,
            x: 0, y: isPressed ? 2 : 4
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed { isPressed = true }
                }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(listing.title) by \(listing.donorName), \(listing.quantity), pickup at \(listing.pickupAddress)")
        .contextMenu {
            Button {
                PSHaptics.light()
            } label: {
                Label("Share Listing", systemImage: "square.and.arrow.up")
            }

            Button {
                PSHaptics.light()
            } label: {
                Label("Copy Address", systemImage: "doc.on.doc")
            }

            Divider()

            Button(role: .destructive) {
                PSHaptics.warning()
            } label: {
                Label("Report", systemImage: "flag")
            }
        } preview: {
            ListingCardView(listing: listing)
                .frame(width: 320)
                .padding()
        }
    }

    private var foodPlaceholder: some View {
        ZStack {
            Color(.systemGray5)
            VStack(spacing: 4) {
                Image(systemName: "fork.knife")
                    .font(.title)
                    .foregroundStyle(Color.psTextSecondary.opacity(0.4))
                Text("No photo")
                    .font(.caption2)
                    .foregroundStyle(Color.psTextSecondary.opacity(0.4))
            }
        }
    }
}

#Preview {
    ListingCardView(listing: FoodListing(
        id: "1",
        donorId: "u1",
        donorName: "Rahim Uncle",
        title: "Wedding Biryani - Fresh & Hot",
        description: "Leftover biryani from a wedding reception",
        category: .biryani,
        quantity: "Serves 20",
        imageURLs: [],
        pickupAddress: "Dhanmondi 27, Block A",
        latitude: 23.8103,
        longitude: 90.4125,
        isHalal: true,
        isAvailable: true,
        expiresAt: Date.hoursFromNow(3),
        createdAt: Date()
    ))
    .padding()
}
