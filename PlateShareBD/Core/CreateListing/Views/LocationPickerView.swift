//
//  LocationPickerView.swift
//  PlateShareBD
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerView: View {
    @Binding var address: String
    @Binding var latitude: Double
    @Binding var longitude: Double

    @State private var cameraPosition: MapCameraPosition
    @State private var pinCoordinate: CLLocationCoordinate2D
    @State private var isGeocoding = false
    @State private var pinIsMoving = false
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var showSearchResults = false
    @FocusState private var searchFocused: Bool
    @Environment(\.dismiss) private var dismiss

    private let geocoder = CLGeocoder()

    // Bangladesh bounding region — biases MKLocalSearch to BD results
    private static let bangladeshRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: AppConstants.Location.bangladeshCenterLatitude,
            longitude: AppConstants.Location.bangladeshCenterLongitude
        ),
        span: MKCoordinateSpan(latitudeDelta: 5.5, longitudeDelta: 5.5)
    )

    init(address: Binding<String>, latitude: Binding<Double>, longitude: Binding<Double>) {
        _address = address
        _latitude = latitude
        _longitude = longitude

        let hasExisting = latitude.wrappedValue != 0 && longitude.wrappedValue != 0
        let coord = CLLocationCoordinate2D(
            latitude: hasExisting ? latitude.wrappedValue : AppConstants.Location.bangladeshCenterLatitude,
            longitude: hasExisting ? longitude.wrappedValue : AppConstants.Location.bangladeshCenterLongitude
        )
        let span = hasExisting
            ? MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
            : MKCoordinateSpan(latitudeDelta: 4.2, longitudeDelta: 4.2)

        _pinCoordinate = State(initialValue: coord)
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(center: coord, span: span)))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Map
                Map(position: $cameraPosition, interactionModes: .all) {
                    UserAnnotation()
                }
                .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.food, .landmark, .publicTransport])))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .onMapCameraChange(frequency: .continuous) { _ in
                    if !pinIsMoving {
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                            pinIsMoving = true
                        }
                    }
                    // Dismiss keyboard when panning
                    if searchFocused { searchFocused = false }
                    if showSearchResults { withAnimation(.easeOut(duration: 0.2)) { showSearchResults = false } }
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    pinCoordinate = context.camera.centerCoordinate
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        pinIsMoving = false
                    }
                    reverseGeocode(pinCoordinate)
                }

                // MARK: - Center Pin (spring-animated)
                VStack(spacing: 0) {
                    ZStack {
                        // Shadow circle under pin
                        Circle()
                            .fill(Color.psAccent.opacity(0.15))
                            .frame(width: 44, height: 44)
                            .scaleEffect(pinIsMoving ? 1.3 : 1.0)

                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundStyle(Color.psAccent)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 22, height: 22)
                            )
                    }
                    .offset(y: pinIsMoving ? -14 : 0)

                    // Ground shadow dot
                    Ellipse()
                        .fill(.black.opacity(pinIsMoving ? 0.08 : 0.2))
                        .frame(width: pinIsMoving ? 16 : 10, height: pinIsMoving ? 5 : 4)
                        .blur(radius: pinIsMoving ? 3 : 1)
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.5), value: pinIsMoving)
                .allowsHitTesting(false)

                // MARK: - Search + Results overlay
                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)

                        TextField("Search: Khulna, KUET, Dhanmondi…", text: $searchText)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .focused($searchFocused)
                            .submitLabel(.search)
                            .onSubmit { performSearch() }
                            .onChange(of: searchText) { _, value in
                                if value.count > 2 { performSearch() }
                                else if value.isEmpty {
                                    searchResults = []
                                    withAnimation(.easeOut) { showSearchResults = false }
                                }
                            }

                        if isSearching {
                            ProgressView().scaleEffect(0.75)
                                .frame(width: 20)
                        } else if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                searchResults = []
                                withAnimation(.easeOut) { showSearchResults = false }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 20)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Search results dropdown
                    if showSearchResults && !searchResults.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(Array(searchResults.enumerated()), id: \.offset) { _, item in
                                Button { selectResult(item) } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: categoryIcon(for: item))
                                            .foregroundStyle(Color.psAccent)
                                            .frame(width: 28)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.name ?? "Unknown")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(.primary)
                                                .lineLimit(1)
                                            if let subtitle = formattedAddress(item) {
                                                Text(subtitle)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.up.left")
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 11)
                                }
                                .buttonStyle(.plain)

                                if item != searchResults.last {
                                    Divider().padding(.leading, 54)
                                }
                            }
                        }
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Spacer()

                    // MARK: - Bottom confirm card
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(isGeocoding ? Color(.systemGray5) : Color.psAccent.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                if isGeocoding {
                                    ProgressView().scaleEffect(0.7)
                                } else {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(Color.psAccent)
                                        .font(.title3)
                                }
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(address.isEmpty
                                     ? (isGeocoding ? "Locating…" : "Move the map to a location")
                                     : address)
                                    .font(.subheadline.weight(address.isEmpty ? .regular : .medium))
                                    .foregroundStyle(address.isEmpty ? Color.secondary : Color.primary)
                                    .lineLimit(2)
                                    .animation(.easeInOut(duration: 0.2), value: address)

                                if !address.isEmpty {
                                    Text(coordinateString)
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                        .monospacedDigit()
                                }
                            }
                            Spacer()
                        }

                        Button {
                            PSHaptics.success()
                            latitude = pinCoordinate.latitude
                            longitude = pinCoordinate.longitude
                            dismiss()
                        } label: {
                            Text("location_picker.confirm")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(hasValidCoordinate ? Color.psAccent : Color(.systemGray4))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!hasValidCoordinate)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.08), radius: 12, y: -4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showSearchResults)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("location_picker.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("location_picker.cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Helpers

    private var hasValidCoordinate: Bool {
        pinCoordinate.latitude != 0 || pinCoordinate.longitude != 0
    }

    private var coordinateString: String {
        String(format: "%.4f°N, %.4f°E", pinCoordinate.latitude, pinCoordinate.longitude)
    }

    private func categoryIcon(for item: MKMapItem) -> String {
        switch item.pointOfInterestCategory {
        case .restaurant, .cafe, .bakery: return "fork.knife"
        case .hospital, .pharmacy: return "cross.case.fill"
        case .school, .university: return "building.columns.fill"
        case .publicTransport, .airport: return "bus.fill"
        default: return "mappin.circle.fill"
        }
    }

    private func formattedAddress(_ item: MKMapItem) -> String? {
        let parts = [item.placemark.subLocality, item.placemark.locality, item.placemark.administrativeArea]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    // MARK: - Search

    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText + " Bangladesh"
        request.region = Self.bangladeshRegion

        Task {
            let results: [MKMapItem]
            if let response = try? await MKLocalSearch(request: request).start() {
                results = Array(response.mapItems.prefix(5))
            } else {
                results = []
            }
            await MainActor.run {
                searchResults = results
                isSearching = false
                withAnimation(.spring(response: 0.3)) {
                    showSearchResults = !results.isEmpty
                }
            }
        }
    }

    private func selectResult(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        let newRegion = MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
        )
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(newRegion)
        }
        pinCoordinate = coord
        address = [item.name, item.placemark.subLocality, item.placemark.locality]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        searchText = ""
        searchResults = []
        withAnimation(.easeOut) { showSearchResults = false }
        searchFocused = false
        PSHaptics.selection()
    }

    // MARK: - Reverse Geocoding

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        guard coordinate.latitude != 0 || coordinate.longitude != 0 else { return }
        isGeocoding = true
        geocoder.cancelGeocode()

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(
            location,
            preferredLocale: Locale(identifier: "en_BD")
        ) { placemarks, _ in
            Task { @MainActor in
                self.isGeocoding = false
                if let pm = placemarks?.first {
                    let parts = [pm.name, pm.subLocality, pm.locality]
                        .compactMap { $0 }
                        .filter { !$0.isEmpty }
                    if !parts.isEmpty {
                        self.address = parts.joined(separator: ", ")
                    }
                }
            }
        }
    }
}
