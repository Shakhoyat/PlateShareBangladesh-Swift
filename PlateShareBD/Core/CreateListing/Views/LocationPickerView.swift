//
//  LocationPickerView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
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
    @State private var dragOffset: CGSize = .zero
    @Environment(\.dismiss) private var dismiss

    private let geocoder = CLGeocoder()

    init(address: Binding<String>, latitude: Binding<Double>, longitude: Binding<Double>) {
        _address = address
        _latitude = latitude
        _longitude = longitude

        let coord = CLLocationCoordinate2D(
            latitude: latitude.wrappedValue != 0 ? latitude.wrappedValue : AppConstants.Location.defaultLatitude,
            longitude: longitude.wrappedValue != 0 ? longitude.wrappedValue : AppConstants.Location.defaultLongitude
        )
        _pinCoordinate = State(initialValue: coord)
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Map — read camera position changes via onMapCameraChange
                Map(position: $cameraPosition, interactionModes: .all) {
                    UserAnnotation()
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    pinCoordinate = context.camera.centerCoordinate
                    reverseGeocode(pinCoordinate)
                }

                // Center pin overlay (stays in center of map)
                VStack(spacing: 0) {
                    Image(systemName: "mappin")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.psAccent)
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

                    // Pin shadow dot
                    Circle()
                        .fill(.black.opacity(0.2))
                        .frame(width: 8, height: 4)
                }

                // Bottom address card
                VStack {
                    Spacer()

                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(.psAccent)
                                .font(.title3)

                            if isGeocoding {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text(address.isEmpty ? "Move the map to select a location" : address)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        Button {
                            latitude = pinCoordinate.latitude
                            longitude = pinCoordinate.longitude
                            dismiss()
                        } label: {
                            Text("Confirm Location")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(address.isEmpty ? Color.gray : Color.psAccent)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(address.isEmpty)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("Select Pickup Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        isGeocoding = true
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                isGeocoding = false
                if let pm = placemarks?.first {
                    let parts = [
                        pm.name,
                        pm.subLocality,
                        pm.locality
                    ].compactMap { $0 }
                    address = parts.joined(separator: ", ")
                }
            }
        }
    }
}
