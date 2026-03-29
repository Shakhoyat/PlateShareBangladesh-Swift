//
//  View+Extensions.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

extension View {
    /// Applies a card-style background with shadow
    func cardStyle() -> some View {
        self
            .background(Color.psBgCard)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    /// Hides the keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
