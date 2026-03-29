//
//  AuthService.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// Typed error enum — never expose raw Firebase errors to ViewModels
enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case wrongPassword
    case tooManyRequests
    case networkError
    case userNotFound
    case profileSetupRequired
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Please enter a valid email address."
        case .weakPassword: return "Password must be at least 6 characters."
        case .emailAlreadyInUse: return "An account with this email already exists. Try signing in."
        case .wrongPassword: return "Incorrect password. Please try again."
        case .tooManyRequests: return "Too many attempts. Please wait before trying again."
        case .networkError: return "No internet connection. Please check your network."
        case .userNotFound: return "No account found with this email."
        case .profileSetupRequired: return "Please complete your profile."
        case .unknown(let msg): return msg
        }
    }
}

@MainActor
final class AuthService {
    static let shared = AuthService()
    private init() {}

    private let db = Firestore.firestore()

    // Register a new user with email and password
    func register(email: String, password: String) async throws -> AuthDataResult {
        do {
            return try await Auth.auth().createUser(withEmail: email, password: password)
        } catch let error as NSError {
            throw mapFirebaseAuthError(error)
        }
    }

    // Sign in with email and password
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        do {
            return try await Auth.auth().signIn(withEmail: email, password: password)
        } catch let error as NSError {
            throw mapFirebaseAuthError(error)
        }
    }

    // Check if user profile exists in Firestore
    func checkUserProfile(uid: String) async throws -> Bool {
        let doc = try await db.collection(FirestoreKeys.Collections.users).document(uid).getDocument()
        return doc.exists
    }

    // Create user profile in Firestore
    func createUserProfile(_ user: PSUser) async throws {
        let data = try Firestore.Encoder().encode(user)
        try await db.collection(FirestoreKeys.Collections.users).document(user.id).setData(data)
    }

    // Fetch user profile
    func fetchUserProfile(uid: String) async throws -> PSUser {
        let doc = try await db.collection(FirestoreKeys.Collections.users).document(uid).getDocument()
        guard let user = try? doc.data(as: PSUser.self) else {
            throw AuthError.userNotFound
        }
        return user
    }

    // Sign out
    func signOut() throws {
        try Auth.auth().signOut()
    }

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    private func mapFirebaseAuthError(_ error: NSError) -> AuthError {
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return .unknown(error.localizedDescription)
        }
        switch code {
        case .invalidEmail: return .invalidEmail
        case .weakPassword: return .weakPassword
        case .emailAlreadyInUse: return .emailAlreadyInUse
        case .wrongPassword: return .wrongPassword
        case .tooManyRequests: return .tooManyRequests
        case .networkError: return .networkError
        case .userNotFound: return .userNotFound
        default: return .unknown(error.localizedDescription)
        }
    }
}
