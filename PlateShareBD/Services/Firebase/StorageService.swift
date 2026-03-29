//
//  StorageService.swift
//  PlateShareBD
//
//  Image uploads use Cloudinary (free tier) instead of Firebase Storage.
//  No SDK needed — plain multipart/form-data POST to the REST API.
//  Cloudinary free plan: 25 GB storage, 25 GB bandwidth/month.
//

import Foundation
import UIKit

enum StorageError: LocalizedError {
    case compressionFailed
    case uploadFailed(String)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .compressionFailed:        return "Could not process image. Please try a different photo."
        case .uploadFailed(let msg):    return "Upload failed: \(msg)"
        case .invalidURL:               return "Invalid upload URL."
        }
    }
}

final class StorageService {
    static let shared = StorageService()
    private init() {}

    // MARK: - Public API

    /// Upload a food listing photo. Returns the Cloudinary CDN URL.
    func uploadFoodImage(_ image: UIImage, userId: String, listingId: String) async throws -> String {
        guard let data = ImageCompressor.compress(image, maxSizeKB: AppConstants.Listing.maxImageSizeKB) else {
            throw StorageError.compressionFailed
        }
        return try await upload(
            imageData: data,
            folder: "listings/\(userId)",
            publicId: "\(listingId)_\(UUID().uuidString.prefix(8))"
        )
    }

    /// Upload a profile avatar. Returns the Cloudinary CDN URL.
    func uploadProfileImage(_ image: UIImage, userId: String) async throws -> String {
        guard let data = ImageCompressor.compress(image, maxSizeKB: 200) else {
            throw StorageError.compressionFailed
        }
        return try await upload(
            imageData: data,
            folder: "profiles",
            publicId: userId
        )
    }

    // MARK: - Private

    private func upload(imageData: Data, folder: String, publicId: String) async throws -> String {
        let cloudName = AppConstants.Cloudinary.cloudName
        guard let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload") else {
            throw StorageError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = buildBody(imageData: imageData, folder: folder, publicId: publicId, boundary: boundary)

        let (responseData, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw StorageError.uploadFailed("No HTTP response")
        }

        // Surface the Cloudinary error message if available
        if http.statusCode != 200 {
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let errorDict = json["error"] as? [String: Any],
               let message = errorDict["message"] as? String {
                throw StorageError.uploadFailed(message)
            }
            throw StorageError.uploadFailed("HTTP \(http.statusCode)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
              let secureURL = json["secure_url"] as? String else {
            throw StorageError.uploadFailed("Unexpected response from Cloudinary")
        }

        return secureURL
    }

    private func buildBody(imageData: Data, folder: String, publicId: String, boundary: String) -> Data {
        var body = Data()
        let crlf = "\r\n"

        func field(_ name: String, _ value: String) {
            body += "--\(boundary)\(crlf)".d
            body += "Content-Disposition: form-data; name=\"\(name)\"\(crlf)\(crlf)".d
            body += "\(value)\(crlf)".d
        }

        field("upload_preset", AppConstants.Cloudinary.uploadPreset)
        field("folder",        folder)
        field("public_id",     publicId)

        // File field
        body += "--\(boundary)\(crlf)".d
        body += "Content-Disposition: form-data; name=\"file\"; filename=\"\(publicId).jpg\"\(crlf)".d
        body += "Content-Type: image/jpeg\(crlf)\(crlf)".d
        body += imageData
        body += "\(crlf)--\(boundary)--\(crlf)".d

        return body
    }
}

private extension String {
    /// Shorthand: convert String to UTF-8 Data
    var d: Data { Data(utf8) }
}
