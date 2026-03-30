//
//  MapView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var viewModel = MapViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedListing: FoodListing?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: AppConstants.Location.defaultLatitude,
                longitude: AppConstants.Location.defaultLongitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition, interactionModes: .all) {
                    // User location
                    UserAnnotation()

                    // Food listing pins
                    ForEach(viewModel.filteredListings) { listing in
                        Annotation(
                            listing.title,
                            coordinate: CLLocationCoordinate2D(
                                latitude: listing.latitude,
                                longitude: listing.longitude
                            ),
                            anchor: .bottom
                        ) {
                            ListingMapPin(listing: listing)
                                .onTapGesture {
                                    selectedListing = listing
                                }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }

                // Overlays
                VStack(spacing: 0) {
                    // Search bar
                    MapSearchBar(
                        text: $viewModel.searchText,
                        isSearching: viewModel.isSearching,
                        onSearch: {
                            viewModel.searchArea()
                        },
                        onClear: {
                            viewModel.clearSearch()
                            recenterOnUser()
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.psError.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.top, 4)
                    }

                    // Listing count pill
                    Text(String(format: NSLocalizedString("map.listings_count", comment: ""), viewModel.filteredListings.count))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.top, 8)

                    Spacer()

                    // Radius selector
                    RadiusSelector(selectedRadius: $viewModel.selectedRadiusKM)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
            }
            .navigationTitle("map.title")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedListing) { listing in
                NavigationStack {
                    ListingMapDetailView(listing: listing, currentUserId: authViewModel.currentUser?.id)
                        .navigationTitle(listing.title)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                viewModel.requestLocationAndLoad()
            }
            .onChange(of: viewModel.userLocation?.latitude) { _, _ in
                if viewModel.searchCenter == nil, let loc = viewModel.userLocation {
                    withAnimation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: loc,
                                span: spanForRadius(viewModel.selectedRadiusKM)
                            )
                        )
                    }
                }
            }
            .onChange(of: viewModel.searchCenter?.latitude) { _, _ in
                if let center = viewModel.searchCenter {
                    withAnimation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: center,
                                span: spanForRadius(viewModel.selectedRadiusKM)
                            )
                        )
                    }
                }
            }
            .onChange(of: viewModel.selectedRadiusKM) { _, newRadius in
                if let center = viewModel.filterCenter {
                    withAnimation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: center,
                                span: spanForRadius(newRadius)
                            )
                        )
                    }
                }
            }
        }
    }

    private func recenterOnUser() {
        if let loc = viewModel.userLocation {
            withAnimation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: loc,
                        span: spanForRadius(viewModel.selectedRadiusKM)
                    )
                )
            }
        }
    }

    /// Convert radius in KM to a reasonable map span
    private func spanForRadius(_ km: Double) -> MKCoordinateSpan {
        let delta = km / 55.0 // ~1° latitude ≈ 111 km, so show 2x radius
        return MKCoordinateSpan(latitudeDelta: delta * 2, longitudeDelta: delta * 2)
    }
}

// MARK: - Search bar component

struct MapSearchBar: View {
    @Binding var text: String
    var isSearching: Bool
    var onSearch: () -> Void
    var onClear: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("map.search_placeholder", text: $text)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                    .onSubmit { onSearch() }
                    .autocorrectionDisabled()

                if !text.isEmpty {
                    Button {
                        onClear()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }

                if isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct ListingMapPin: View {
    let listing: FoodListing

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.psAccent, .psAccentDark],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: .psAccent.opacity(0.4), radius: 4, x: 0, y: 2)

                Image(systemName: listing.category.sfSymbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            // Pin tail
            Triangle()
                .fill(Color.psAccentDark)
                .frame(width: 14, height: 8)
                .offset(y: -2)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct RadiusSelector: View {
    @Binding var selectedRadius: Double

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "scope")
                    .foregroundStyle(Color.psAccent)
                Text("Radius: \(String(format: "%.1f", selectedRadius)) km")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.psTextPrimary)
                Spacer()
                Text("\(Int(selectedRadius * 1000))m")
                    .font(.caption)
                    .foregroundStyle(Color.psTextSecondary)
            }

            Slider(
                value: $selectedRadius,
                in: AppConstants.Location.minRadiusKM...AppConstants.Location.maxRadiusKM,
                step: 0.5
            )
            .tint(.psAccent)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    MapView()
}
