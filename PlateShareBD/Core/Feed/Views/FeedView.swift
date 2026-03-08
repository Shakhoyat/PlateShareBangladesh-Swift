//
//  FeedView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isFilterShowing = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Category filter chips
                        categoryFilterBar
                            .padding(.vertical, 12)

                        // Listings grid
                        if viewModel.filteredListings.isEmpty && !viewModel.isLoading {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredListings) { listing in
                                    NavigationLink(destination: ListingDetailView(listing: listing, currentUserId: authViewModel.currentUser?.id)) {
                                        ListingCardView(listing: listing)
                                    }
                                    .buttonStyle(.plain)
                                    .onAppear {
                                        viewModel.loadMoreIfNeeded(currentItem: listing)
                                    }
                                }

                                if viewModel.isLoading {
                                    ProgressView()
                                        .padding(.vertical, 20)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }

                // Error banner overlays at top
                if viewModel.errorMessage != nil {
                    ErrorBannerView(
                        message: viewModel.errorMessage ?? "",
                        isPresented: .init(
                            get: { viewModel.errorMessage != nil },
                            set: { if !$0 { viewModel.errorMessage = nil } }
                        )
                    )
                }
            }
            .navigationTitle("PlateShare 🍽️")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Category Filter Bar
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(
                    title: "All",
                    emoji: "🍽️",
                    isSelected: viewModel.selectedCategory == nil,
                    action: { viewModel.setCategory(nil) }
                )

                ForEach(FoodListing.FoodCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue.capitalized,
                        emoji: category.emoji,
                        isSelected: viewModel.selectedCategory == category,
                        action: { viewModel.setCategory(category) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.psTextSecondary.opacity(0.4))

            Text("No food available nearby")
                .font(.headline)
                .foregroundColor(.psTextPrimary)

            Text("Be the first to share! Tap + to create a listing.")
                .font(.subheadline)
                .foregroundColor(.psTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
        .padding(.horizontal, 40)
    }
}

struct CategoryChip: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 14))
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.psGreen : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .psTextPrimary)
            .cornerRadius(20)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

#Preview {
    FeedView()
}
