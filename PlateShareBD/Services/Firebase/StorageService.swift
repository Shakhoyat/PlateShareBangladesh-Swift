//
//  StorageService.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import FirebaseStorage
import UIKit

enum StorageError: LocalizedError {
    case compressionFailed
    case uploadFailed(String)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .compressionFailed: return "Could not process image. Please try a different photo."
        case .uploadFailed(let msg): return "Upload failed: \(msg)"
        case .invalidURL: return "Could not get download URL."
        }
    }
}

final class StorageService {
    static let shared = StorageService()
    private init() {}

    private let storage = Storage.storage()

    // Upload food photo — returns download URL string
    // Path: listings/{userId}/{listingId}/{uuid}.jpg — matches Firebase Storage rules for per-user writes
    func uploadFoodImage(
        _ image: UIImage,
        userId: String,
        listingId: String
    ) async throws -> String {
        // Step 1: Compress (CRITICAL for Bangladesh's mobile data costs)
        guard let compressed = ImageCompressor.compress(image, maxSizeKB: AppConstants.Listing.maxImageSizeKB) else {
            throw StorageError.compressionFailed
        }

        // Step 2: Create storage reference
        let filename = "\(UUID().uuidString).jpg"
        let ref = storage.reference().child("listings/\(userId)/\(listingId)/\(filename)")

        // Step 3: Set metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Step 4: Upload
        do {
            _ = try await ref.putData(compressed, metadata: metadata)
        } catch {
            throw StorageError.uploadFailed(error.localizedDescription)
        }

        // Step 5: Get download URL (retry once if storage needs propagation time)
        do {
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            // Retry after a brief delay — Firebase Storage can have propagation lag
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            do {
                let url = try await ref.downloadURL()
                return url.absoluteString
            } catch {
                throw StorageError.uploadFailed(error.localizedDescription)
            }
        }
    }

    // Upload profile photo
    func uploadProfileImage(_ image: UIImage, userId: String) async throws -> String {
        guard let compressed = ImageCompressor.compress(image, maxSizeKB: 200) else {
            throw StorageError.compressionFailed
        }

        let ref = storage.reference().child("profiles/\(userId)/avatar.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putData(compressed, metadata: metadata)
        do {
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            let url = try await ref.downloadURL()
            return url.absoluteString
        }
    }
}
