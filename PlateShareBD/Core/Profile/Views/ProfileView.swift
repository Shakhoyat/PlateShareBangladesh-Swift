//
//  ProfileView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Error banner
                    if let error = viewModel.errorMessage {
                        ErrorBannerView(
                            message: error,
                            isPresented: .init(
                                get: { viewModel.errorMessage != nil },
                                set: { if !$0 { viewModel.errorMessage = nil } }
                            )
                        )
                    }

                    // Profile Header
                    profileHeader

                    // Stats Cards
                    statsSection

                    // My Listings
                    myListingsSection

                    // Settings
                    settingsSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .navigationTitle("profile.title")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            PSAvatarView(
                imageURL: viewModel.user?.profileImageURL,
                size: 80,
                showBadge: viewModel.user?.isVerified ?? false
            )

            VStack(spacing: 4) {
                Text(viewModel.user?.displayName ?? NSLocalizedString("profile.loading", comment: ""))
                    .font(.title3.weight(.bold))
                    .foregroundColor(.psTextPrimary)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.psSecondary)
                    Text(viewModel.user?.area ?? "")
                        .font(.subheadline)
                        .foregroundColor(.psTextSecondary)
                }
            }

            // Rating
            if let rating = viewModel.user?.donorRating, rating > 0 {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.psSecondary)
                    }
                    Text(String(format: "%.1f", rating))
                        .font(.caption.weight(.medium))
                        .foregroundColor(.psTextSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.psBgCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // MARK: - Stats
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                value: "\(viewModel.user?.totalDonations ?? 0)",
                label: NSLocalizedString("profile.donations", comment: ""),
                icon: "gift.fill",
                color: .psAccent
            )
            StatCard(
                value: "\(viewModel.myListings.filter { $0.isAvailable }.count)",
                label: NSLocalizedString("profile.active", comment: ""),
                icon: "clock.fill",
                color: .psSecondary
            )
            StatCard(
                value: String(format: "%.1f", viewModel.user?.donorRating ?? 0.0),
                label: NSLocalizedString("profile.rating", comment: ""),
                icon: "star.fill",
                color: .yellow
            )
        }
    }

    // MARK: - My Listings
    private var myListingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("profile.my_listings")
                .font(.headline)
                .foregroundColor(.psTextPrimary)

            if viewModel.myListings.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundColor(.psTextSecondary.opacity(0.4))
                    Text("profile.no_listings")
                        .font(.subheadline)
                        .foregroundColor(.psTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                ForEach(viewModel.myListings) { listing in
                    MyListingRow(listing: listing) {
                        Task { await viewModel.markListingTaken(listing) }
                    } onDelete: {
                        Task { await viewModel.deleteListing(listing) }
                    }
                }
            }
        }
    }

    // MARK: - Settings
    private var settingsSection: some View {
        VStack(spacing: 0) {
            Button {
                Task { await viewModel.toggleLanguage() }
            } label: {
                SettingsRow(icon: "globe", title: NSLocalizedString("profile.language", comment: ""), value: viewModel.user?.preferredLanguage == "bn" ? "বাংলা" : "English")
            }
            Divider().padding(.leading, 44)
            Button {
                if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                SettingsRow(icon: "bell.fill", title: NSLocalizedString("profile.notifications", comment: ""), value: "")
            }
            Divider().padding(.leading, 44)
            SettingsRow(icon: "shield.fill", title: NSLocalizedString("profile.privacy", comment: ""), value: "")
            Divider().padding(.leading, 44)

            // Sign Out
            Button {
                authViewModel.signOut()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.psError)
                        .frame(width: 24)
                    Text("profile.sign_out")
                        .foregroundColor(.psError)
                    Spacer()
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
            }
        }
        .background(Color.psBgCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.psTextPrimary)

            Text(label)
                .font(.caption2)
                .foregroundColor(.psTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.psBgCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct MyListingRow: View {
    let listing: FoodListing
    let onMarkTaken: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: listing.category.sfSymbol)
                .font(.title3)
                .foregroundColor(.psAccent)
                .frame(width: 44, height: 44)
                .background(Color.psAccent.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(listing.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.psTextPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    PSBadgeView(
                        text: listing.isAvailable ? "Active" : "Taken",
                        color: listing.isAvailable ? .psAccent : .psTextSecondary
                    )
                    Text(listing.createdAt.timeAgo)
                        .font(.caption2)
                        .foregroundColor(.psTextSecondary)
                }
            }

            Spacer()

            if listing.isAvailable {
                Menu {
                    Button("Mark as Taken", action: onMarkTaken)
                    Button("Delete", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.psTextSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.psBgCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.psAccent)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.psTextPrimary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.psTextSecondary)
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(.psTextSecondary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
