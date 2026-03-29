//
//  RatingView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct RatingView: View {
    let donorId: String
    let donorName: String
    let listingId: String
    let currentUserId: String

    @State private var selectedScore: Int = 0
    @State private var comment: String = ""
    @State private var isSubmitting = false
    @State private var didSubmit = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 6) {
                Text(NSLocalizedString("rating.title", comment: ""))
                    .font(.title3.bold())
                    .foregroundStyle(Color.psTextPrimary)
                Text(NSLocalizedString("rating.subtitle", comment: ""))
                    .font(.subheadline)
                    .foregroundStyle(Color.psTextSecondary)
                Text(donorName)
                    .font(.headline)
                    .foregroundStyle(Color.psAccent)
            }

            // Star selector
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= selectedScore ? "star.fill" : "star")
                        .font(.title)
                        .foregroundStyle(star <= selectedScore ? Color.psSecondary : Color.psTextSecondary.opacity(0.3))
                        .onTapGesture { selectedScore = star }
                        .accessibilityLabel("\(star) star")
                }
            }
            .padding(.vertical, 8)

            // Comment
            TextField(NSLocalizedString("rating.comment_placeholder", comment: ""), text: $comment, axis: .vertical)
                .lineLimit(3...5)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if didSubmit {
                Label(NSLocalizedString("rating.thanks", comment: ""), systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.psSuccess)
                    .font(.subheadline.weight(.medium))
            }

            PSButton(
                NSLocalizedString("rating.submit", comment: ""),
                isLoading: isSubmitting
            ) {
                Task { await submitRating() }
            }
            .disabled(selectedScore == 0 || didSubmit)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 24)
    }

    private func submitRating() async {
        isSubmitting = true
        let rating = PSRating(
            fromUserId: currentUserId,
            toUserId: donorId,
            listingId: listingId,
            score: selectedScore,
            comment: comment.isEmpty ? nil : comment,
            createdAt: Date()
        )
        do {
            try await FirestoreService.shared.submitRating(rating)
            didSubmit = true
        } catch {
            // Error handled silently — could add banner in future
        }
        isSubmitting = false
    }
}

#Preview {
    RatingView(
        donorId: "u1",
        donorName: "Rahim Uncle",
        listingId: "listing1",
        currentUserId: "me"
    )
}
