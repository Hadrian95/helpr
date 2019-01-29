//
//  Job.swift
//  helpr
//
//  Created by adrian.parcioaga on 2018-10-30.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CodableFirebase

class Job{
    
    //MARK: Properties
    var information: JobInformation
    var pictureData: [UIImage]
    
    
    //MARK: Initialization
    init?(title: String, category: String, description: String, pictureURLs: [String], tags: [String], distance: Int, postalCode: String, postedTime: Date, email: String) {
        
        information = JobInformation(title: title, category: category, description: description, pictures: pictureURLs, tags: tags, distance: distance, postalCode: postalCode, postedTime: postedTime, email: email)!
        
        pictureData = [UIImage(named: "defaultPhoto")!]
    }
    
    init?(jobInformation: JobInformation) {
        information = jobInformation
        pictureData = [UIImage(named: "defaultPhoto")!]

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
                let photo = UIImage(named: "comphelp")
                UIImagePictures.append(photo)
                break
            case "Tutoring":
                let photo = UIImage(named: "TutorDefault")
                UIImagePictures.append(photo)
                break
            case "Cleaning":
                let photo = UIImage(named: "cleaning")
                UIImagePictures.append(photo)
                break
            default:
                break
            }
            
        }
        return UIImagePictures
    }

    
}
