//
//  JobInformation.swift
//  helpr
//
//  Created by Hilmi Abou-Saleh on 2018-11-28.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

struct CustomGeoPoint : Codable {
    var latitude: Double
    var longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}

class JobInformation: Codable {
    //MARK: Properties
    var title: String
    var category: String
    var postDescription: String
    var pictures = [String?]() // contains urls for images
    var tags = [String?]()
    var address: [String : String]
    var location = CustomGeoPoint(latitude: 0,longitude: 0)
    var anonLocation = CustomGeoPoint(latitude: 0, longitude: 0)
    var distance: Int
    var postalCode: String
    var postedTime: Date
    var favourite: Bool
    var email: String
    var firebaseID: String
    var id: Int
    
    //MARK: Initialization
    
    init?(title: String, category: String, description: String, pictures: [String?], tags: [String], address: [String : String], location: GeoPoint, anonLocation: GeoPoint, distance: Int, postalCode: String, postedTime: Date, email: String, id: Int) {
        self.title = title
        self.category = category
        self.postDescription = description
        self.email = email
        self.pictures = pictures
        if (!tags.isEmpty){
            self.tags = tags
        }else {
            self.tags = ["test tags"]
        }
        self.address = address
        self.location = CustomGeoPoint(latitude: location.latitude, longitude: location.longitude)
        self.anonLocation = CustomGeoPoint(latitude: anonLocation.latitude, longitude: anonLocation.longitude)
        self.distance = distance
        self.favourite = false
        if (!postalCode.isEmpty){
            self.postalCode = postalCode
        }else{
            self.postalCode = "T1K 3J7"
        }
        self.postedTime = postedTime
        
        self.firebaseID = UUID().uuidString
        self.id = id
    }
    
    init?(title: String, category: String, description: String, pictures: [String?], tags: [String], address: [String : String], location: GeoPoint, anonLocation: GeoPoint, distance: Int, postalCode: String, postedTime: Date, email: String, firebaseID: String, id: Int) {
        self.title = title
        self.category = category
        self.postDescription = description
        self.email = email
        self.pictures = pictures
        if (!tags.isEmpty){
            self.tags = tags
        }else {
            self.tags = ["test tags"]
        }
        self.address = address
        self.location = CustomGeoPoint(latitude: location.latitude, longitude: location.longitude)
        self.anonLocation = CustomGeoPoint(latitude: anonLocation.latitude, longitude: anonLocation.longitude)
        self.distance = distance
        self.favourite = false
        if (!postalCode.isEmpty){
            self.postalCode = postalCode
        }else{
            self.postalCode = "T1K 3J7"
        }
        self.postedTime = postedTime
        
        self.firebaseID = firebaseID
        self.id = id
    }
}
