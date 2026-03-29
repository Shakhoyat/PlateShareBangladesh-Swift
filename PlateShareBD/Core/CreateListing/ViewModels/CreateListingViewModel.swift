//
//  CreateListingViewModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseAuth
import UIKit

@MainActor
final class CreateListingViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var category: FoodListing.FoodCategory = .other
    @Published var quantity = ""
    @Published var pickupAddress = ""
    @Published var pickupLatitude: Double = 0
    @Published var pickupLongitude: Double = 0
    @Published var isHalal = true
    @Published var expiryHours = AppConstants.Listing.defaultExpiryHours
    @Published var selectedImages: [UIImage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSuccess = false

    private let firestoreService = FirestoreService.shared
    private let storageService = StorageService.shared
    private let locationService = LocationService.shared

    var isFormValid: Bool {
        !title.isEmpty && !quantity.isEmpty && !pickupAddress.isEmpty
    }

    func createListing() async {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be logged in to create a listing."
            return
        }

        guard isFormValid else {
            errorMessage = "Please fill in all required fields."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let listingId = UUID().uuidString

            // Upload images
            var imageURLs: [String] = []
            for image in selectedImages {
                let url = try await storageService.uploadFoodImage(image, userId: currentUID, listingId: listingId)
                imageURLs.append(url)
            }

            // Use selected location or fall back to current/default
            let latitude = pickupLatitude != 0 ? pickupLatitude
                : (locationService.currentLocation?.coordinate.latitude ?? AppConstants.Location.defaultLatitude)
            let longitude = pickupLongitude != 0 ? pickupLongitude
                : (locationService.currentLocation?.coordinate.longitude ?? AppConstants.Location.defaultLongitude)

            // Fetch current user name
            let user = try await firestoreService.fetchUser(uid: currentUID)

            let listing = FoodListing(
                id: listingId,
                donorId: currentUID,
                donorName: user.displayName,
                title: title,
                description: description.isEmpty ? nil : description,
                category: category,
                quantity: quantity,
                imageURLs: imageURLs,
                pickupAddress: pickupAddress,
                latitude: latitude,
                longitude: longitude,
                isHalal: isHalal,
                isAvailable: true,
                expiresAt: Date.hoursFromNow(expiryHours),
                createdAt: Date()
            )

            try await firestoreService.createListing(listing)

            // Update user's total donations
            try await firestoreService.updateUser(uid: currentUID, data: [
                "totalDonations": (user.totalDonations + 1)
            ])

            isSuccess = true
            resetForm()
        } catch {
            errorMessage = "Failed to create listing: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func addImage(_ image: UIImage) {
        guard selectedImages.count < AppConstants.Listing.maxPhotoCount else {
            errorMessage = "Maximum \(AppConstants.Listing.maxPhotoCount) photos allowed."
            return
        }
        selectedImages.append(image)
    }

    func removeImage(at index: Int) {
        selectedImages.remove(at: index)
    }

    private func resetForm() {
        title = ""
        description = ""
        category = .other
        quantity = ""
        pickupAddress = ""
        pickupLatitude = 0
        pickupLongitude = 0
        isHalal = true
        expiryHours = AppConstants.Listing.defaultExpiryHours
        selectedImages = []
    }
}
