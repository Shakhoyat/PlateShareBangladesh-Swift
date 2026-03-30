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
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                                ForEach(Array(viewModel.filteredListings.enumerated()), id: \.element.id) { index, listing in
                                    NavigationLink(destination: ListingDetailView(listing: listing, currentUserId: authViewModel.currentUser?.id)) {
                                        ListingCardView(listing: listing)
                                    }
                                    .buttonStyle(.plain)
                                    .opacity(appeared ? 1 : 0)
                                    .offset(y: appeared || reduceMotion ? 0 : 24)
                                    .animation(
                                        reduceMotion ? .linear(duration: 0.1) :
                                            .spring(response: 0.5, dampingFraction: 0.7)
                                            .delay(Double(min(index, 6)) * 0.05),
                                        value: appeared
                                    )
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
                    PSHaptics.medium()
                    await viewModel.refresh()
                }
                .onAppear {
                    guard !appeared else { return }
                    withAnimation { appeared = true }
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
            .navigationTitle("feed.title")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Category Filter Bar
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(
                    title: "All",
                    sfSymbol: "fork.knife",
                    isSelected: viewModel.selectedCategory == nil,
                    action: {
                        PSHaptics.selection()
                        viewModel.setCategory(nil)
                    }
                )

                ForEach(FoodListing.FoodCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue.capitalized,
                        sfSymbol: category.sfSymbol,
                        isSelected: viewModel.selectedCategory == category,
                        action: {
                            PSHaptics.selection()
                            viewModel.setCategory(category)
                        }
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
                .foregroundStyle(Color.psTextSecondary.opacity(0.4))

            Text("feed.empty.title")
                .font(.headline)
                .foregroundStyle(Color.psTextPrimary)

            Text("feed.empty.subtitle")
                .font(.subheadline)
                .foregroundStyle(Color.psTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
        .padding(.horizontal, 40)
    }
}

struct CategoryChip: View {
    let title: String
    let sfSymbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: sfSymbol)
                    .font(.system(size: 12))
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.psAccent : Color(.systemGray6))
            .foregroundStyle(isSelected ? Color.white : Color.psTextPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

#Preview {
    FeedView()
}
