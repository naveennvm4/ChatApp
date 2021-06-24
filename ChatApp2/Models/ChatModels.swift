//
//  ChatModels.swift
//  ChatApp
//
//  Created by MackBookAir on 05/06/21.
//

import Foundation
import UIKit
import MessageKit

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}


extension MessageKind{
    var messageKindString: String{
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "video"
        case .emoji(_):
            return "video"
        case .audio(_):
            return "video"
        case .contact(_):
            return "video"
        case .linkPreview(_):
            return "video"
        case .custom(_):
            return "video"
        }
    }
}


struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

