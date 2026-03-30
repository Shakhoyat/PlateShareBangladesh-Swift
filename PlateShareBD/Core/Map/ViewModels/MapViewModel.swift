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
    private var searchTask: Task<Void, Never>?

    /// Effective center for radius filtering: search result → user location → KUET default.
    /// Non-optional so seed listings around KUET are always visible before GPS resolves.
    var filterCenter: CLLocationCoordinate2D {
        searchCenter ?? userLocation ?? CLLocationCoordinate2D(
            latitude: AppConstants.Location.kuetLatitude,
            longitude: AppConstants.Location.kuetLongitude
        )
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
        searchTask?.cancel()
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

    /// Search for an area name and re-center the map.
    /// - Parameter currentRegion: The live camera region from MapView used as locality bias.
    ///   Falls back to the Bangladesh-wide region when nil.
    /// 300 ms debounce cancels any in-flight request before starting a new one.
    func searchArea(in currentRegion: MKCoordinateRegion? = nil) {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            clearSearch()
            return
        }

        searchTask?.cancel()
        isSearching = true
        errorMessage = nil

        let searchRegion = currentRegion ?? Self.bangladeshRegion

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else {
                isSearching = false
                return
            }

            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query + " Bangladesh"
            request.region = searchRegion

            do {
                let response = try await MKLocalSearch(request: request).start()
                guard !Task.isCancelled else { return }
                if let coord = response.mapItems.first?.placemark.coordinate {
                    searchCenter = coord
                    filterByRadius()
                } else {
                    errorMessage = "Could not find \"\(query)\""
                }
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = "Could not find \"\(query)\""
            }
            isSearching = false
        }
    }

    func clearSearch() {
        searchTask?.cancel()
        searchText = ""
        searchCenter = nil
        errorMessage = nil
        filterByRadius()
    }

    private func filterByRadius() {
        let center = filterCenter
        let radiusMeters = selectedRadiusKM * 1000
        filteredListings = listings.filter { listing in
            let listingLocation = CLLocation(latitude: listing.latitude, longitude: listing.longitude)
            let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            return centerLocation.distance(from: listingLocation) <= radiusMeters
        }
    }
}
