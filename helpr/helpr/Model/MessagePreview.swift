//
//  MessagePreview.swift
//  helpr
//
//  Created by Critical on 2019-03-04.
//  Copyright © 2019 ryan.konynenbelt. All rights reserved.
//

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
