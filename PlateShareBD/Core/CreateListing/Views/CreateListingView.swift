//
//  CreateListingView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI
import PhotosUI

struct CreateListingView: View {
    @StateObject private var viewModel = CreateListingViewModel()
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showSuccessAlert = false
    @State private var showLocationPicker = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Photo Picker Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("create.photos")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.psTextPrimary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Add photo button
                                if viewModel.selectedImages.count < AppConstants.Listing.maxPhotoCount {
                                    PhotosPicker(
                                        selection: $selectedPhotos,
                                        maxSelectionCount: AppConstants.Listing.maxPhotoCount - viewModel.selectedImages.count,
                                        matching: .images
                                    ) {
                                        VStack(spacing: 6) {
                                            Image(systemName: "camera.fill")
                                                .font(.title2)
                                            Text("create.add_photo")
                                                .font(.caption2)
                                        }
                                        .foregroundStyle(Color.psAccent)
                                        .frame(width: 100, height: 100)
                                        .background(Color.psAccent.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.psAccent.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6]))
                                        )
                                    }
                                }

                                // Selected images
                                ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: viewModel.selectedImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))

                                        Button {
                                            viewModel.removeImage(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(Color.white)
                                                .background(Circle().fill(.black.opacity(0.5)))
                                        }
                                        .offset(x: 4, y: -4)
                                    }
                                }
                            }
                        }
                    }

                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("create.food_title")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.psTextSecondary)
                        PSTextField(
                            placeholder: "create.title_placeholder",
                            text: $viewModel.title,
                            icon: "fork.knife"
                        )
                    }

                    // Category Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("create.category")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.psTextSecondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(FoodListing.FoodCategory.allCases, id: \.self) { category in
                                    Button {
                                        viewModel.category = category
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: category.sfSymbol)
                                                .font(.caption)
                                            Text(category.rawValue.capitalized)
                                                .font(.caption.weight(.medium))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(viewModel.category == category ? Color.psAccent : Color(.systemGray6))
                                        .foregroundStyle(viewModel.category == category ? Color.white : Color.psTextPrimary)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                    }
                                }
                            }
                        }
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("create.description")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.psTextSecondary)
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $viewModel.description)
                                .frame(height: 80)
                            if viewModel.description.isEmpty {
                                Text("create.title_placeholder")
                                    .font(.body)
                                    .foregroundStyle(Color(.placeholderText))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }

                    // Quantity
                    VStack(alignment: .leading, spacing: 6) {
                        Text("create.quantity")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.psTextSecondary)
                        PSTextField(
                            placeholder: "create.quantity_placeholder",
                            text: $viewModel.quantity,
                            icon: "person.2.fill"
                        )
                    }

                    // Pickup Address — map pin selector
                    VStack(alignment: .leading, spacing: 6) {
                        Text("create.pickup_address")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.psTextSecondary)

                        Button {
                            showLocationPicker = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundStyle(Color.psTextSecondary)
                                    .frame(width: 20)
                                Text(viewModel.pickupAddress.isEmpty
                                     ? String(localized: "location_picker.tap_to_select")
                                     : viewModel.pickupAddress)
                                    .font(.body)
                                    .foregroundStyle(viewModel.pickupAddress.isEmpty ? Color.psTextSecondary : Color.psTextPrimary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "map.fill")
                                    .foregroundStyle(Color.psAccent)
                            }
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }
                    }

                    // Halal toggle & Expiry
                    HStack(spacing: 16) {
                        Toggle(isOn: $viewModel.isHalal) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(Color.psAccent)
                                Text("create.halal")
                                    .font(.subheadline.weight(.medium))
                            }
                        }
                        .tint(.psAccent)
                    }

                    // Expiry — chip row instead of segmented (6 items too cramped on SE)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("create.hours")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.psTextSecondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach([2, 4, 6, 8, 12, 24], id: \.self) { hours in
                                    Button {
                                        viewModel.expiryHours = hours
                                    } label: {
                                        Text("\(hours)h")
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(viewModel.expiryHours == hours ? Color.psAccent : Color(.systemGray6))
                                            .foregroundStyle(viewModel.expiryHours == hours ? Color.white : Color.psTextPrimary)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                    }
                                }
                            }
                        }
                    }

                    // Submit
                    PSButton(String(localized: "create.submit"), isLoading: viewModel.isLoading) {
                        Task { await viewModel.createListing() }
                    }
                    .disabled(!viewModel.isFormValid)
                    .padding(.top, 8)

                    // Upload warning (non-fatal: listing saved but photos missing)
                    if let warning = viewModel.imageUploadWarning {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.psWarning)
                            Text(warning)
                                .font(.caption)
                                .foregroundStyle(Color.psWarning)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(12)
                        .background(Color.psWarning.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Error
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(Color.psError)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("create.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onChange(of: selectedPhotos) { _, newItems in
                Task {
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            viewModel.addImage(image)
                        }
                    }
                    selectedPhotos = []
                }
            }
            .onChange(of: viewModel.isSuccess) { _, success in
                if success {
                    PSHaptics.success()
                    showSuccessAlert = true
                }
            }
            .alert(String(localized: "create.success_title"), isPresented: $showSuccessAlert) {
                Button("common.ok") { dismiss() }
            } message: {
                Text("create.success_message")
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView(
                    address: $viewModel.pickupAddress,
                    latitude: $viewModel.pickupLatitude,
                    longitude: $viewModel.pickupLongitude
                )
            }
        }
    }
}

#Preview {
    CreateListingView()
}
