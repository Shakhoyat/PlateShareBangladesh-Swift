//
//  MessageModel.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation

struct PSMessage: Codable, Identifiable {
    let id: String
    let senderId: String
    let conversationId: String
    var text: String?
    var audioURL: String?             // for voice messages (Phase 2)
    var isRead: Bool
    var createdAt: Date
}
