//
//  AuthViewModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseAuth
import Combine
import UIKit

enum AuthState: Equatable {
    case unauthenticated
    case authenticating
    case needsProfileSetup
    case authenticated
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .unauthenticated
    @Published var currentUser: PSUser?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let authService = AuthService.shared
    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    private func listenToAuthState() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    await self?.handleAuthenticatedUser(uid: user.uid)
                } else {
                    self?.authState = .unauthenticated
                    self?.currentUser = nil
                }
            }
        }
    }

    private func handleAuthenticatedUser(uid: String) async {
        do {
            let profileExists = try await authService.checkUserProfile(uid: uid)
            if profileExists {
                let user = try await authService.fetchUserProfile(uid: uid)
                self.currentUser = user
                self.authState = .authenticated
                LanguageManager.shared.setLanguage(user.preferredLanguage)
            } else {
                self.authState = .needsProfileSetup
            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.authState = .unauthenticated
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.signIn(email: email, password: password)
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Sign in failed. Please try again."
        }
        isLoading = false
    }

    func register(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.register(email: email, password: password)
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Registration failed. Please try again."
        }
        isLoading = false
    }

    func completeProfileSetup(displayName: String, area: String, profileImage: UIImage?) async {
        guard let uid = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else {
            errorMessage = "Authentication error. Please try again."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Image upload is best-effort — profile is created even if it fails
            var profileImageURL: String? = nil
            if let image = profileImage {
                profileImageURL = try? await StorageService.shared.uploadProfileImage(image, userId: uid)
            }

            let user = PSUser(
                id: uid,
                displayName: displayName,
                email: email,
                area: area,
                profileImageURL: profileImageURL,
                isVerified: false,
                donorRating: 0.0,
                totalDonations: 0,
                fcmToken: nil,
                preferredLanguage: AppConstants.Languages.english,
                createdAt: Date()
            )

            try await authService.createUserProfile(user)
            self.currentUser = user
            self.authState = .authenticated
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = "Could not sign out. Please try again."
        }
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
