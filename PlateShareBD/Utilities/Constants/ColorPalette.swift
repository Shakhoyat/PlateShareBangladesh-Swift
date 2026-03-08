//
//  ColorPalette.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

extension Color {
    // Primary brand colors
    static let psGreen = Color(hex: "2ECC71")
    static let psGreenDark = Color(hex: "27AE60")
    static let psGreenLight = Color(hex: "A8E6CF")

    // Secondary / accent
    static let psOrange = Color(hex: "F39C12")
    static let psOrangeLight = Color(hex: "F5B041")
    static let psWarmYellow = Color(hex: "F9E79F")

    // Backgrounds (semantic — auto light/dark)
    static let psBgPrimary = Color(.systemBackground)
    static let psBgCard = Color(.secondarySystemGroupedBackground)
    static let psBgDark = Color(hex: "1A1A2E")

    // Text (semantic — auto light/dark)
    static let psTextPrimary = Color(.label)
    static let psTextSecondary = Color(.secondaryLabel)

    // Semantic
    static let psError = Color(hex: "E74C3C")
    static let psSuccess = Color(hex: "2ECC71")
    static let psWarning = Color(hex: "F39C12")

    // Helper init from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
