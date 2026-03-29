//
//  ImageCompressor.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import UIKit

struct ImageCompressor {
    /// Compress an image to stay within a maximum file size in kilobytes.
    /// Reduces JPEG quality first, then resizes if still too large.
    static func compress(_ image: UIImage, maxSizeKB: Int = 500) -> Data? {
        let maxBytes = maxSizeKB * 1024
        var compression: CGFloat = 0.8

        // First try at target quality
        guard var data = image.jpegData(compressionQuality: compression) else { return nil }

        // Reduce quality until under size limit
        while data.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            data = image.jpegData(compressionQuality: compression) ?? data
        }

        // If still too large, resize the image
        if data.count > maxBytes {
            let scale = sqrt(Double(maxBytes) / Double(data.count))
            let newSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let resized = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
            return resized.jpegData(compressionQuality: 0.7)
        }

        return data
    }
}
