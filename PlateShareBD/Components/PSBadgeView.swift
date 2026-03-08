//
//  PSBadgeView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct PSBadgeView: View {
    let text: String
    var color: Color = .psGreen
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 11, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .cornerRadius(6)
    }
}

#Preview {
    HStack {
        PSBadgeView(text: "Halal", icon: "checkmark.circle.fill")
        PSBadgeView(text: "Verified", color: .blue, icon: "checkmark.seal.fill")
        PSBadgeView(text: "Expires Soon", color: .psOrange, icon: "clock")
    }
}
