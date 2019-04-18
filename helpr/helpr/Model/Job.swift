//
//  Job.swift
//  helpr
//
//  Created by adrian.parcioaga on 2018-10-30.
//  Copyright © 2018 helpr. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CodableFirebase

class Job {
    
    //MARK: Properties
    var information: JobInformation
    var pictureData: [UIImage] // contains actual post pictures
    
    
    //MARK: Initialization
    init?(title: String, category: String, description: String, pictureURLs: [String], tags: [String], address: [String : String], location: GeoPoint, anonLocation: GeoPoint, distance: Int, postalCode: String, postedTime: Date, email: String, id: Int) {
        
        information = JobInformation(title: title, category: category, description: description, pictures: pictureURLs, tags: tags, address: address, location: location, anonLocation: anonLocation, distance: distance, postalCode: postalCode, postedTime: postedTime, email: email, id: id)!
        
        pictureData = []
    }
    
    //init with id
    init?(title: String, category: String, description: String, pictureURLs: [String], tags: [String], address: [String : String], location: GeoPoint, anonLocation: GeoPoint, distance: Int, postalCode: String, postedTime: Date, email: String, firebaseID: String, id: Int) {
        
        information = JobInformation(title: title, category: category, description: description, pictures: pictureURLs, tags: tags, address: address, location: location, anonLocation: anonLocation, distance: distance, postalCode: postalCode, postedTime: postedTime, email: email, firebaseID: firebaseID, id: id)!
        
        pictureData = []
    }
    
    init?(jobInformation: JobInformation) {
        information = jobInformation
        pictureData = []
    }
    
    func getPictures() -> [UIImage?]{
        var UIImagePictures = [UIImage?]()
        if (!information.pictures.isEmpty) {
            for picture in information.pictures {
                UIImagePictures.append(UIImage(named: picture!))
            }
        }
        else {
            switch (information.category) {
            case "Technology":
                let photo = UIImage(named: "techDefault")
                UIImagePictures.append(photo)
                break
            case "Tutoring":
                let photo = UIImage(named: "tutorDefault")
                UIImagePictures.append(photo)
                break
            case "Cleaning":
                let photo = UIImage(named: "cleanDefault")
                UIImagePictures.append(photo)
                break
            default:
                break
            }
        }
        return UIImagePictures
    }
}
