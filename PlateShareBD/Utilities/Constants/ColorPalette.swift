//
//  ColorPalette.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

extension Color {
    // ── Primary accent — warm terracotta ──
    static let psAccent = Color(hex: "C45C3C")       // Warm terracotta
    static let psAccentDark = Color(hex: "A14028")    // Deep terracotta
    static let psAccentLight = Color(hex: "E8A990")   // Light peach

    // ── Secondary — saffron gold ──
    static let psSecondary = Color(hex: "D4912A")     // Saffron / turmeric
    static let psSecondaryLight = Color(hex: "F2D398") // Light gold

    // ── Neutral warm tones ──
    static let psWarmGray = Color(hex: "8B7E74")      // Warm gray
    static let psCream = Color(hex: "FAF5EF")         // Off-white cream

    // Legacy aliases (keep existing references compiling)
    static let psGreen = Color.psAccent
    static let psGreenDark = Color.psAccentDark
    static let psGreenLight = Color.psAccentLight
    static let psOrange = Color.psSecondary
    static let psOrangeLight = Color.psSecondaryLight
    static let psWarmYellow = Color.psSecondaryLight

    // Backgrounds (semantic — auto light/dark)
    static let psBgPrimary = Color(.systemBackground)
    static let psBgCard = Color(.secondarySystemGroupedBackground)
    static let psBgDark = Color(hex: "2C2420")

    // Text (semantic — auto light/dark)
    static let psTextPrimary = Color(.label)
    static let psTextSecondary = Color(.secondaryLabel)

    // Semantic states
    static let psError = Color(hex: "C0392B")
    static let psSuccess = Color(hex: "27AE60")
    static let psWarning = Color(hex: "D4912A")

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
