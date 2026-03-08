//
//  ConversationModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation

struct PSConversation: Codable, Identifiable {
    let id: String
    let listingId: String
    let participantIds: [String]      // [donorId, recipientId]
    var lastMessage: String?
    var lastMessageAt: Date?
    var unreadCount: Int
}
