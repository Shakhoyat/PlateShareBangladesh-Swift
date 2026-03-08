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
    @Published var hasMorePages = true
    @Published var selectedCategory: FoodListing.FoodCategory?

    private var lastDocument: DocumentSnapshot?
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

    // Real-time listener for feed
    private func startListening() {
        firestoreService.listingsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] listings in
                self?.listings = listings
            }
            .store(in: &cancellables)
    }

    func loadListings() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let (newListings, lastDoc) = try await firestoreService
                    .fetchListings(limit: AppConstants.Pagination.pageSize, after: lastDocument)

                self.listings.append(contentsOf: newListings)
                self.lastDocument = lastDoc
                self.hasMorePages = newListings.count == AppConstants.Pagination.pageSize
            } catch let error as AppError {
                self.errorMessage = error.errorDescription
            } catch {
                self.errorMessage = "Unexpected error. Please try again."
            }
            self.isLoading = false
        }
    }

    func loadMoreIfNeeded(currentItem: FoodListing) {
        guard hasMorePages else { return }
        let thresholdIndex = max(listings.count - 5, 0)
        if let currentIndex = listings.firstIndex(where: { $0.id == currentItem.id }),
           currentIndex >= thresholdIndex {
            loadListings()
        }
    }

    func refresh() async {
        listings = []
        lastDocument = nil
        hasMorePages = true
        loadListings()
    }

    func setCategory(_ category: FoodListing.FoodCategory?) {
        selectedCategory = category
    }
}
