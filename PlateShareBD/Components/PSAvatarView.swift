//
//  PSAvatarView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct PSAvatarView: View {
    let imageURL: String?
    var size: CGFloat = 44
    var showBadge: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let url = imageURL, let imageUrl = URL(string: url) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholderView
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: size)
                    @unknown default:
                        placeholderView
                    }
                }
                .frame(width: size, height: size)
                .clipShape(Circle())
            } else {
                placeholderView
            }

            if showBadge {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: size * 0.3))
                    .foregroundColor(.psGreen)
                    .background(
                        Circle()
                            .fill(.white)
                            .frame(width: size * 0.35, height: size * 0.35)
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(showBadge ? "Verified user avatar" : "User avatar")
    }

    private var placeholderView: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(.psTextSecondary.opacity(0.5))
    }
}

#Preview {
    HStack(spacing: 16) {
        PSAvatarView(imageURL: nil, size: 40)
        PSAvatarView(imageURL: nil, size: 60, showBadge: true)
    }
}
