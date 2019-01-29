//
//  UserProfile.swift
//  helpr
//
//  Created by adrian.parcioaga on 2018-11-19.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit
import os.log

struct Skill {
    private var skillName : String
    
    init? (skill: String) {
        skillName = skill
    }
}

struct Review {
    
}

struct Settings {
    
}

class UserProfile: NSObject, NSCoding {

    //MARK: Properties
    var name : String
//    private var phoneNumber : Int
    var email : String
//    private var rating : Float
//    private var homeAddress : String
//    private var profilePic : UIImage
//    private var featReviews : [Review]
//    private var skills : [Skill]
//    private var settings : Settings

    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("userProfile")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let email = "email"
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a UserProfile object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let email = aDecoder.decodeObject(forKey: PropertyKey.email) as? String else {
            os_log("Unable to decode the name for a UserProfile object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Must call designated initializer.
        self.init(name: name, email: email)
        
    }
    init?(name: String, email: String) {
        self.name = name
        self.email = email
        
    }
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(email, forKey: PropertyKey.email)
    }
    
    //MARK: Active User
    static func loadProfile() -> UserProfile? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: self.ArchiveURL.path) as? UserProfile
    }
    
}
