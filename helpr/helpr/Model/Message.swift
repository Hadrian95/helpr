//
//  Message.swift
//  helpr
//
//  Created by walter.alvarez on 2019-03-26.
//  Copyright © 2019 helpr. All rights reserved.
//
// message object that dequeues Firestore messages into renderable chat bubbles

import Foundation
import UIKit

class Message: NSObject {
    
    var senderId: String?
    var senderName: String?
    var text: String?
    var timestamp: Date?
    
    init(dictionary: [String: Any]) {
        self.senderId = dictionary["senderID"] as? String
        self.senderName = dictionary["senderName"] as? String
        self.text = dictionary["content"] as? String
        self.timestamp = dictionary["created"] as? Date
    }
}
