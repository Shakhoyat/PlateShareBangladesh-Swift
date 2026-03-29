//
//  PSButtonStyle.swift
//  PlateShareBD
//

import SwiftUI

struct PSButton: View {
    let title: String
    var isLoading: Bool = false
    var style: PSButtonType = .primary
    let action: () -> Void

    @State private var isPressed = false

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
        Button {
            PSHaptics.medium()
            action()
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.8)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(
                color: backgroundColor.opacity(isPressed ? 0.1 : 0.3),
                radius: isPressed ? 2 : 8,
                x: 0, y: isPressed ? 1 : 4
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.8 : 1.0)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed { isPressed = true }
                }
                .onEnded { _ in isPressed = false }
        )
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return .psAccent
        case .secondary: return .psOrange
        case .destructive: return .psError
        }
    }

    private var foregroundColor: Color { .white }
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
