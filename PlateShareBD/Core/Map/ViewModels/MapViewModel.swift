//
//  MapViewModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class MapViewModel: ObservableObject {
    @Published var listings: [FoodListing] = []
    @Published var filteredListings: [FoodListing] = []
    @Published var selectedRadiusKM: Double = AppConstants.Location.defaultRadiusKM
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firestoreService = FirestoreService.shared
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Listen to location changes
        locationService.$currentLocation
            .compactMap { $0?.coordinate }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                self?.userLocation = coordinate
                self?.filterByRadius()
            }
            .store(in: &cancellables)

        // Listen to radius changes
        $selectedRadiusKM
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterByRadius()
            }
            .store(in: &cancellables)

        // Listen to listings updates
        firestoreService.listingsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] listings in
                self?.listings = listings
                self?.filterByRadius()
            }
            .store(in: &cancellables)
    }

    func requestLocationAndLoad() {
        locationService.requestPermission()
        locationService.startUpdating()
    }

    private func filterByRadius() {
        filteredListings = locationService.listingsWithinRadius(listings, radiusKM: selectedRadiusKM)
    }
}
