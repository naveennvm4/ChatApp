//
//  ConversationsModels.swift
//  ChatApp
//
//  Created by MackBookAir on 05/06/21.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
