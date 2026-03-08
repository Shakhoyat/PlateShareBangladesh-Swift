//
//  ListingCardView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct ListingCardView: View {
    let listing: FoodListing

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
                .cornerRadius(8)
                .padding(8)
            }

            // Details
            VStack(alignment: .leading, spacing: 8) {
                Text(listing.title)
                    .font(.headline)
                    .foregroundColor(.psTextPrimary)
                    .lineLimit(2)

                // Donor info
                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .font(.caption)
                        .foregroundColor(.psTextSecondary)
                    Text(listing.donorName)
                        .font(.caption)
                        .foregroundColor(.psTextSecondary)
                }

                // Location & time row
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.psSecondary)
                        Text(listing.pickupAddress.truncated(to: 25))
                            .font(.caption2)
                            .foregroundColor(.psTextSecondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(listing.expiresAt.isExpired ? .psError : .psTextSecondary)
                        Text(listing.expiresAt.timeAgo)
                            .font(.caption2)
                            .foregroundColor(listing.expiresAt.isExpired ? .psError : .psTextSecondary)
                    }
                }

                // Tags
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
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(listing.title) by \(listing.donorName), \(listing.quantity), pickup at \(listing.pickupAddress)")
    }

    private var foodPlaceholder: some View {
        ZStack {
            Color(.systemGray5)
            VStack(spacing: 4) {
                Image(systemName: "fork.knife")
                    .font(.title)
                    .foregroundColor(.psTextSecondary.opacity(0.4))
                Text("No photo")
                    .font(.caption2)
                    .foregroundColor(.psTextSecondary.opacity(0.4))
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
