//
//  User.swift
//  helpr
//
//  Created by adrian.parcioaga on 2019-02-07.
//  Copyright © 2019 helpr. All rights reserved.
//
// locally stored user's info

import UIKit
import Foundation

class UserInfo {
    var name : String
    var email : String
    var skills : [String]
    var pic : UIImage?
    var jobs : [Job]
    var posts : [Post]
    var conversations : [String]
    var settings : [Settings]
    var reviews : [Review]
    var picRef : String
    
    init() {
        name = ""
        email = ""
        skills = []
        pic = nil
        jobs = []
        posts = []
        conversations = []
        settings = []
        reviews = []
        picRef = ""
    }
}
