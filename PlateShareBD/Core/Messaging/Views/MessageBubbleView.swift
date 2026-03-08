//
//  MessageBubbleView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: PSMessage
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text ?? "")
                    .font(.body)
                    .foregroundColor(isFromCurrentUser ? .white : .psTextPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isFromCurrentUser
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [.psGreen, .psGreenDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                          )
                        : AnyShapeStyle(Color(.systemGray6))
                    )
                    .cornerRadius(18, corners: isFromCurrentUser
                        ? [.topLeft, .topRight, .bottomLeft]
                        : [.topLeft, .topRight, .bottomRight]
                    )

                Text(message.createdAt.chatTime)
                    .font(.system(size: 10))
                    .foregroundColor(.psTextSecondary)
                    .padding(.horizontal, 4)
            }

            if !isFromCurrentUser { Spacer(minLength: 60) }
        }
    }
}

// Custom corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    VStack(spacing: 8) {
        MessageBubbleView(
            message: PSMessage(id: "1", senderId: "me", conversationId: "c1", text: "Is the biryani still available?", isRead: true, createdAt: Date()),
            isFromCurrentUser: true
        )
        MessageBubbleView(
            message: PSMessage(id: "2", senderId: "other", conversationId: "c1", text: "Yes! Come pick it up before 8 PM. It's still warm 😊", isRead: false, createdAt: Date()),
            isFromCurrentUser: false
        )
    }
    .padding()
}
