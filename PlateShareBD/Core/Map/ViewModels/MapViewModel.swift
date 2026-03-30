//
//  MapViewModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import CoreLocation
import MapKit
import Combine
import FirebaseFirestore

@MainActor
final class MapViewModel: ObservableObject {
    @Published var listings: [FoodListing] = []
    @Published var filteredListings: [FoodListing] = []
    @Published var selectedRadiusKM: Double = AppConstants.Location.defaultRadiusKM
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Search
    @Published var searchText = ""
    @Published var searchCenter: CLLocationCoordinate2D?
    @Published var isSearching = false

    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()
    private var listingsListener: ListenerRegistration?

    /// The effective center for radius filtering — search result or user location
    var filterCenter: CLLocationCoordinate2D? {
        searchCenter ?? userLocation
    }

    init() {
        // Listen to location changes
        locationService.$currentLocation
            .compactMap { $0?.coordinate }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                self?.userLocation = coordinate
                if self?.searchCenter == nil {
                    self?.filterByRadius()
                }
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
        listingsListener = Firestore.firestore()
            .collection(FirestoreKeys.Collections.listings)
            .order(by: FirestoreKeys.ListingFields.createdAt, descending: true)
            .limit(to: 200)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if let docs = snapshot?.documents {
                        self.listings = docs.compactMap { try? $0.data(as: FoodListing.self) }
                        self.filterByRadius()
                    }
                }
            }
    }

    deinit {
        listingsListener?.remove()
    }

    func requestLocationAndLoad() {
        locationService.requestPermission()
        locationService.startUpdating()
    }

    // Bangladesh region used to bias MKLocalSearch results
    private static let bangladeshRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: AppConstants.Location.bangladeshCenterLatitude,
            longitude: AppConstants.Location.bangladeshCenterLongitude
        ),
        span: MKCoordinateSpan(latitudeDelta: 5.5, longitudeDelta: 5.5)
    )

    // Search for an area name and re-center
    func searchArea() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            clearSearch()
            return
        }

        isSearching = true
        errorMessage = nil

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query + " Bangladesh"
        request.region = Self.bangladeshRegion

        Task {
            do {
                let response = try await MKLocalSearch(request: request).start()
                if let coord = response.mapItems.first?.placemark.coordinate {
                    searchCenter = coord
                    filterByRadius()
                } else {
                    errorMessage = "Could not find \"\(query)\""
                }
            } catch {
                errorMessage = "Could not find \"\(query)\""
            }
            isSearching = false
        }
    }

    func clearSearch() {
        searchText = ""
        searchCenter = nil
        errorMessage = nil
        filterByRadius()
    }

    private func filterByRadius() {
        guard let center = filterCenter else {
            filteredListings = listings
            return
        }
        let radiusMeters = selectedRadiusKM * 1000
        filteredListings = listings.filter { listing in
            let listingLocation = CLLocation(latitude: listing.latitude, longitude: listing.longitude)
            let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            return centerLocation.distance(from: listingLocation) <= radiusMeters
        }
    }
}
