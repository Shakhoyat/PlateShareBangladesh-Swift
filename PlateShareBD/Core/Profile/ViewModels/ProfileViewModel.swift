//
//  ProfileViewModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseAuth

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: PSUser?
    @Published var myListings: [FoodListing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firestoreService = FirestoreService.shared

    init() {
        loadProfile()
    }

    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true

        Task {
            do {
                user = try await firestoreService.fetchUser(uid: uid)
                myListings = try await firestoreService.fetchUserListings(donorId: uid)
            } catch {
                errorMessage = "Failed to load profile."
            }
            isLoading = false
        }
    }

    func deleteListing(_ listing: FoodListing) async {
        do {
            try await firestoreService.deleteListing(listingId: listing.id)
            myListings.removeAll { $0.id == listing.id }
        } catch {
            errorMessage = "Failed to delete listing."
        }
    }

    func markListingTaken(_ listing: FoodListing) async {
        do {
            try await firestoreService.markListingTaken(listingId: listing.id)
            if let index = myListings.firstIndex(where: { $0.id == listing.id }) {
                myListings[index].isAvailable = false
            }
        } catch {
            errorMessage = "Failed to update listing."
        }
    }

    func toggleLanguage() async {
        guard let uid = Auth.auth().currentUser?.uid,
              var currentUser = user else { return }

        let newLang = currentUser.preferredLanguage == AppConstants.Languages.bangla
            ? AppConstants.Languages.english
            : AppConstants.Languages.bangla

        do {
            try await firestoreService.updateUser(uid: uid, data: [
                FirestoreKeys.UserFields.preferredLanguage: newLang
            ])
            currentUser.preferredLanguage = newLang
            self.user = currentUser
        } catch {
            errorMessage = "Failed to update language."
        }
    }
}
