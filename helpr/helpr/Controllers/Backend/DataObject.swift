//
//  DataObject.swift
//  helpr
//
//  Created by Hilmi Abou-Saleh on 2018-11-25.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import Firebase
class DataObject: NSObject {
    
    let snapshot: DataSnapshot
    var key: String { return snapshot.key }
    var ref: DatabaseReference { return snapshot.ref }
    
    required init(snapshot: DataSnapshot) {
        
        self.snapshot = snapshot
        
        super.init()
        
        for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
            if responds(to: Selector(child.key)) {
                setValue(child.value, forKey: child.key)
            }
        }
    }
}

protocol DatabaseReferenceable {
    var ref: DatabaseReference { get }
}

extension DatabaseReferenceable {
    var ref: DatabaseReference {
        return Database.database().reference()
    }
}
