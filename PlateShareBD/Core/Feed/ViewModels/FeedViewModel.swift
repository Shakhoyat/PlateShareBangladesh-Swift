//
//  FeedViewModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var listings: [FoodListing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: FoodListing.FoodCategory?

    private var cancellables = Set<AnyCancellable>()
    private let firestoreService: FirestoreService

    var filteredListings: [FoodListing] {
        guard let category = selectedCategory else { return listings }
        return listings.filter { $0.category == category }
    }

    init(firestoreService: FirestoreService = .shared) {
        self.firestoreService = firestoreService
        startListening()
    }

    // Real-time listener for feed — primary data source
    private func startListening() {
        isLoading = true
        firestoreService.listingsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] listings in
                self?.listings = listings
                self?.isLoading = false
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
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
}
