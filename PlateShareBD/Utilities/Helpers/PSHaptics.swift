//
//  PSHaptics.swift
//  PlateShareBD
//

import UIKit

enum PSHaptics {
    /// Light tap — navigation, row selection
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Medium tap — primary button press, card confirm
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Heavy — destructive confirm, force press
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    /// Success — form submitted, item saved, message sent
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Error — validation failure, network error
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    /// Warning — before destructive action
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Selection click — tab switch, picker, toggle
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
