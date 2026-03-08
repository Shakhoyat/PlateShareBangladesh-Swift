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
                Map(position: $cameraPosition) {
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

                // Bottom radius selector
                VStack {
                    Spacer()
                    RadiusSelector(selectedRadius: $viewModel.selectedRadiusKM)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
            }
            .navigationTitle("Nearby Food 📍")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedListing) { listing in
                ListingDetailView(listing: listing, currentUserId: authViewModel.currentUser?.id)
                    .presentationDetents([.medium, .large])
            }
            .onAppear {
                viewModel.requestLocationAndLoad()
            }
            .onChange(of: viewModel.userLocation?.latitude) { _, _ in
                if let loc = viewModel.userLocation {
                    withAnimation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: loc,
                                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                            )
                        )
                    }
                }
            }
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
                            colors: [.psGreen, .psGreenDark],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: .psGreen.opacity(0.4), radius: 4, x: 0, y: 2)

                Text(listing.category.emoji)
                    .font(.system(size: 22))
            }

            // Pin tail
            Triangle()
                .fill(Color.psGreenDark)
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
                    .foregroundColor(.psGreen)
                Text("Radius: \(String(format: "%.1f", selectedRadius)) km")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.psTextPrimary)
                Spacer()
                Text("\(Int(selectedRadius * 1000))m")
                    .font(.caption)
                    .foregroundColor(.psTextSecondary)
            }

            Slider(
                value: $selectedRadius,
                in: AppConstants.Location.minRadiusKM...AppConstants.Location.maxRadiusKM,
                step: 0.5
            )
            .tint(.psGreen)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    MapView()
}
