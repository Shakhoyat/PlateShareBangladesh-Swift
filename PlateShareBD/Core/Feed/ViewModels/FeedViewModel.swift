//
//  FeedViewModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseFirestore

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var listings: [FoodListing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: FoodListing.FoodCategory?

    private var listingsListener: ListenerRegistration?
    private let firestoreService: FirestoreService

    var filteredListings: [FoodListing] {
        guard let category = selectedCategory else { return listings }
        return listings.filter { $0.category == category }
    }

    init(firestoreService: FirestoreService = .shared) {
        self.firestoreService = firestoreService
        startListening()
    }

    // Real-time listener for feed — properly cancelled on deinit
    private func startListening() {
        isLoading = true
        listingsListener?.remove()

        listingsListener = Firestore.firestore()
            .collection(FirestoreKeys.Collections.listings)
            .order(by: FirestoreKeys.ListingFields.createdAt, descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                        return
                    }
                    guard let documents = snapshot?.documents else {
                        self.isLoading = false
                        return
                    }
                    let now = Date()
                    self.listings = documents
                        .compactMap { try? $0.data(as: FoodListing.self) }
                        .filter { $0.isAvailable && $0.expiresAt > now }
                    self.isLoading = false
                    self.errorMessage = nil
                }
            }
    }

    // Pull-to-refresh: one-shot fetch from server
    func refresh() async {
        errorMessage = nil
        do {
            let freshListings = try await firestoreService.fetchListings()
            self.listings = freshListings
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func setCategory(_ category: FoodListing.FoodCategory?) {
        selectedCategory = category
    }

    deinit {
        listingsListener?.remove()
    }
}
