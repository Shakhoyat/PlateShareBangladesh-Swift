//
//  ListingMapDetailView.swift
//  PlateShareBD
//

import SwiftUI
import MapKit
import UIKit

struct ListingMapDetailView: View {
    let listing: FoodListing
    let currentUserId: String?

    @State private var cameraPosition: MapCameraPosition
    @State private var showDetail = true
    @State private var isShowingChat = false
    @State private var conversation: PSConversation?
    @State private var isLoadingChat = false
    @State private var isReserving = false
    @State private var chatError: String?
    @State private var donor: PSUser?
    @Environment(\.dismiss) private var dismiss

    init(listing: FoodListing, currentUserId: String?) {
        self.listing = listing
        self.currentUserId = currentUserId
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: listing.latitude,
                    longitude: listing.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
            )
        ))
    }

    var isOwnListing: Bool { currentUserId == listing.donorId }

    var body: some View {
        Map(position: $cameraPosition, interactionModes: .all) {
            UserAnnotation()
            Annotation(
                listing.title,
                coordinate: CLLocationCoordinate2D(
                    latitude: listing.latitude,
                    longitude: listing.longitude
                ),
                anchor: .bottom
            ) {
                ListingMapPin(listing: listing)
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.restaurant, .cafe, .bakery, .landmark, .publicTransport])))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    PSHaptics.light()
                    openInMaps()
                } label: {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.psAccent)
                }
                .accessibilityLabel("Get Directions")
            }
        }
        .sheet(isPresented: $showDetail) {
            NavigationStack {
                detailContent
                    .navigationTitle(listing.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(isPresented: $isShowingChat) {
                        if let conv = conversation {
                            ChatView(conversation: conv, otherUserName: listing.donorName)
                                .navigationTitle(listing.donorName)
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
            }
            .presentationDetents([.medium, .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .interactiveDismissDisabled()
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
        }
        .task {
            donor = try? await FirestoreService.shared.fetchUser(uid: listing.donorId)
        }
    }

    // MARK: - Detail Sheet Content

    private var detailContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Photo strip
                photoStrip

                VStack(alignment: .leading, spacing: 14) {
                    // Badges
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
                        if !listing.isAvailable {
                            PSBadgeView(text: "Taken", color: .psError, icon: "xmark.circle.fill")
                        }
                    }

                    Divider()

                    // Donor
                    HStack(spacing: 12) {
                        PSAvatarView(
                            imageURL: donor?.profileImageURL,
                            size: 40,
                            showBadge: donor?.isVerified ?? false
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(listing.donorName)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.psTextPrimary)
                            if donor?.isVerified == true {
                                Text("Verified Donor")
                                    .font(.caption)
                                    .foregroundStyle(Color.psAccent)
                            }
                        }
                        Spacer()
                        Text(listing.createdAt.timeAgo)
                            .font(.caption)
                            .foregroundStyle(Color.psTextSecondary)
                    }

                    // Description
                    if let desc = listing.description, !desc.isEmpty {
                        Text(desc)
                            .font(.body)
                            .foregroundStyle(Color.psTextSecondary)
                    }

                    // Pickup address
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Color.psSecondary)
                        Text(listing.pickupAddress)
                            .font(.subheadline)
                            .foregroundStyle(Color.psTextSecondary)
                    }

                    Divider()

                    // Action buttons
                    VStack(spacing: 10) {
                        // Reserve — primary CTA for non-owner, available, not-yet-expired
                        if !isOwnListing && listing.isAvailable && !listing.expiresAt.isExpired {
                            PSButton("Reserve This Food", isLoading: isReserving) {
                                Task { await reserveListing() }
                            }
                            .accessibilityLabel("Reserve \(listing.title)")
                        }

                        // Secondary row: Directions + Message
                        HStack(spacing: 10) {
                            Button {
                                PSHaptics.light()
                                openInMaps()
                            } label: {
                                Label("Directions", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 44)
                                    .background(Color(.systemGray6))
                                    .foregroundStyle(Color.psTextPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            if !isOwnListing && listing.isAvailable {
                                Button {
                                    PSHaptics.medium()
                                    Task { await startChat() }
                                } label: {
                                    Group {
                                        if isLoadingChat {
                                            ProgressView().tint(.white)
                                        } else {
                                            Label("Message", systemImage: "message.fill")
                                                .font(.subheadline.weight(.semibold))
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 44)
                                    .background(Color.psAccent)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .disabled(isLoadingChat)
                                .accessibilityLabel("Message \(listing.donorName)")
                            }
                        }

                        // Call — only visible if donor opted in with phoneNumber
                        if !isOwnListing, let phone = donor?.phoneNumber {
                            Button {
                                PSHaptics.medium()
                                callDonor(phone: phone)
                            } label: {
                                Label("Call Donor", systemImage: "phone.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 44)
                                    .background(Color(.systemGray6))
                                    .foregroundStyle(Color.psTextPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .accessibilityLabel("Call \(listing.donorName)")
                        }

                        if let error = chatError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(Color.psError)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(16)
            }
        }
    }

    @ViewBuilder
    private var photoStrip: some View {
        if !listing.imageURLs.isEmpty {
            TabView {
                ForEach(listing.imageURLs, id: \.self) { urlString in
                    if let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                                    .clipped()
                            case .failure:
                                Color(.systemGray6)
                                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                            case .empty:
                                ZStack {
                                    Color(.systemGray6)
                                    ProgressView()
                                }
                                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                            @unknown default:
                                Color(.systemGray6)
                                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                            }
                        }
                    }
                }
            }
            .frame(height: 200)
            .tabViewStyle(.page)
            .clipped()
        }
    }

    // MARK: - Actions

    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: listing.latitude, longitude: listing.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = listing.title
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
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
            PSHaptics.success()
            self.isShowingChat = true
        } catch {
            self.chatError = "Could not open chat. Please try again."
        }
        isLoadingChat = false
    }

    /// Reserve: opens chat and sends a pre-composed reservation message.
    /// No new Firestore field needed — conversation creation is the reservation signal.
    private func reserveListing() async {
        guard let currentUID = currentUserId else { return }
        isReserving = true
        chatError = nil
        do {
            let conv = try await FirestoreService.shared.getOrCreateConversation(
                listingId: listing.id,
                donorId: listing.donorId,
                recipientId: currentUID
            )
            try await FirestoreService.shared.sendMessage(
                conversationId: conv.id,
                text: "Hi! I'd like to reserve this food. Is it still available?"
            )
            self.conversation = conv
            PSHaptics.success()
            self.isShowingChat = true
        } catch {
            self.chatError = "Could not send reservation. Please try again."
        }
        isReserving = false
    }

    private func callDonor(phone: String) {
        let cleaned = phone.filter { $0.isNumber || $0 == "+" }
        guard let url = URL(string: "tel://\(cleaned)") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
