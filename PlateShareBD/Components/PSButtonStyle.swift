//
//  PSButtonStyle.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct PSButton: View {
    let title: String
    var isLoading: Bool = false
    var style: PSButtonType = .primary
    let action: () -> Void

    enum PSButtonType {
        case primary
        case secondary
        case destructive
    }

    init(_ title: String, isLoading: Bool = false, style: PSButtonType = .primary, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .shadow(color: backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.8 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return .psAccent
        case .secondary: return .psOrange
        case .destructive: return .psError
        }
    }

    private var foregroundColor: Color {
        return .white
    }
}

#Preview {
    VStack(spacing: 16) {
        PSButton("Share Food", action: {})
        PSButton("Loading...", isLoading: true, action: {})
        PSButton("Delete", style: .destructive, action: {})
        PSButton("Secondary", style: .secondary, action: {})
    }
    .padding()
}
