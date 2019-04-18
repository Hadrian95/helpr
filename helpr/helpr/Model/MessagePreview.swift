//
//  MessagePreview.swift
//  helpr
//
//  Created by adrian.parcioaga on 2019-03-04.
//  Copyright © 2019 helpr. All rights reserved.
//
// renders the chat row in the MessagesTableViewController

import Foundation
import UIKit
import Firebase
import CodableFirebase

class MessagePreview {
    var senderName = ""
    var mPreview = ""
    var picture: UIImage?
    var bidAmt = ""
    var mTime = ""
    var partnerID = ""
    var partnerPicRef = ""
    var chatID = ""
    var accepted = false
    var job: Job?
    var bid: Bid?
    
    init?(name: String, preview: String, pic: UIImage, bid: String, time: String, chatID: String) {
        senderName = name
        mPreview = preview
        picture = pic
        bidAmt = bid
        mTime = time
    }
    
    init?() {
        
    }
}
