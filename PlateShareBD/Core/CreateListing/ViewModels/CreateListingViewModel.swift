//
//  CreateListingViewModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
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
    @Published var imageUploadWarning: String?

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
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        imageUploadWarning = nil

        do {
            let listingId = UUID().uuidString

            // Fetch user FIRST — fail fast before spending time on uploads.
            // Fall back to Firebase Auth display name if profile doc is missing.
            let donorName: String
            do {
                let user = try await firestoreService.fetchUser(uid: currentUID)
                donorName = user.displayName
            } catch {
                donorName = Auth.auth().currentUser?.displayName ?? "Anonymous"
            }

            // Upload images — URLSession is already async so this never blocks the UI.
            // Individual failures are non-fatal; listing is created with whatever
            // uploads succeeded, and a warning is shown for any failures.
            var imageURLs: [String] = []
            var failedUploads = 0
            for image in selectedImages {
                do {
                    let url = try await storageService.uploadFoodImage(image, userId: currentUID, listingId: listingId)
                    imageURLs.append(url)
                } catch {
                    failedUploads += 1
                }
            }
            if failedUploads > 0 {
                imageUploadWarning = failedUploads == selectedImages.count
                    ? "Photos couldn't be saved — check your Cloudinary setup."
                    : "\(failedUploads) photo(s) failed to upload and won't appear on the listing."
            }

            // Use selected location or fall back to current/default
            let latitude = pickupLatitude != 0 ? pickupLatitude
                : (locationService.currentLocation?.coordinate.latitude ?? AppConstants.Location.defaultLatitude)
            let longitude = pickupLongitude != 0 ? pickupLongitude
                : (locationService.currentLocation?.coordinate.longitude ?? AppConstants.Location.defaultLongitude)

            let listing = FoodListing(
                id: listingId,
                donorId: currentUID,
                donorName: donorName,
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

            // Use FieldValue.increment to avoid read-then-write race condition
            try await firestoreService.updateUser(uid: currentUID, data: [
                "totalDonations": FieldValue.increment(Int64(1))
            ])

            isSuccess = true
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
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
