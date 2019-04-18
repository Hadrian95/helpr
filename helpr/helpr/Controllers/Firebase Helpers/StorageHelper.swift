//
//  StorageHelper.swift
//  helpr
//
//  Created by walter alvarez and adrian parcioaga on 2018-11-25.
//  Copyright © 2018 helpr. All rights reserved.
//

import Firebase
import FirebaseStorage

class StorageHelper{
    let storage: Storage
    let storageRef:StorageReference
    init() {
        storage = Storage.storage()
        storageRef = storage.reference()
    }
    
    private func getProfilePictureReference() -> StorageReference {
        //User must be logged in to upload photo.
        return storageRef.child("profilePictures").child(Auth.auth().currentUser!.uid)
    }
    private func getJobReference(job: Job) -> StorageReference {
        return storageRef.child("jobPictures").child(job.information.firebaseID)
    }
    
    func saveImages(job: Job, imagesArray : [UIImage], createJob: Bool, jobID: String){
        job.pictureData = imagesArray
        uploadImages(root: "jobPictures", ID: jobID, imagesArray : imagesArray){ (uploadedImageUrlsArray) in
            job.information.pictures = uploadedImageUrlsArray
            
            let database = DatabaseHelper()
            let userID = Auth.auth().currentUser?.uid
            let dataToSave = ["id": job.information.id, "category": job.information.category, "description": job.information.postDescription, "address": job.information.address, "anonLocation": GeoPoint(latitude: job.information.anonLocation.latitude, longitude: job.information.anonLocation.longitude), "location": GeoPoint(latitude: job.information.location.latitude, longitude: job.information.location.longitude), "postedTime": Date(), "posterID": userID!, "title": job.information.title, "pictureURLs": job.information.pictures] as [String : Any]
            
            database.addJobInformation(dataToSave: dataToSave, tags: job.information.tags as! [String], jobID: jobID) {
                (error) in
                if error != nil {
                    print(error!._code)
                }else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addedPost"), object: nil)
                }
            }
        }
    }
    
    func loadImages(job: Job){
        if job.information.pictures.count < 1 { return }
        
        downloadImages(jobID: job.information.firebaseID, images: job.information.pictures as! [String]){ downloadedImages in
            job.pictureData = downloadedImages
            print("Anything")
        }
    }
    
    func downloadImages(jobID: String, images: [String], completionHandler: @escaping ([UIImage]) -> ()){
        var downloadedImages = [UIImage]()
        var downloadCount = 0
        let imagesCount = images.count
        
        for image in images {
            let ref = storageRef.child(image)
            let downloadData = ref.getData(maxSize: 15 * 1024 * 1024){ (data, error) in
                if error != nil{
                    print(error?.localizedDescription)
                    return
                }
                downloadedImages.append(UIImage(data: data!)!)
                downloadCount += 1
                print("Number of images successfully downloaded: \(downloadCount)")
                if downloadCount == imagesCount{
                    NSLog("All Images are downloaded successfully, downloadedImages: \(downloadedImages)")
                    completionHandler(downloadedImages)
                }
            }
        }
    }
    
    func uploadImages(root: String, ID: String, imagesArray : [UIImage], completionHandler: @escaping ([String]) -> ()){
        
        var uploadedImageUrlsArray = [String]()
        var uploadCount = 0
        let imagesCount = imagesArray.count
        
        for image in imagesArray{
            
            let imageName = NSUUID().uuidString // Unique string to reference image
            
            //Create storage reference for image
            let ref = storageRef.child(root).child(ID).child("\(imageName).png")
            
            
            guard let uploadData = image.jpegData(compressionQuality: 0.8)  else{
                return
            }
            
            // Upload image to firebase
            let uploadTask = ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error)
                    return
                }
                let imageUrl = ref.fullPath
                print(imageUrl)
                uploadedImageUrlsArray.append(imageUrl)
                
                uploadCount += 1
                print("Number of images successfully uploaded: \(uploadCount)")
                if uploadCount == imagesCount{
                    NSLog("All Images are uploaded successfully, uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
                    completionHandler(uploadedImageUrlsArray)
                }
            })
            
            observeUploadTaskFailureCases(uploadTask : uploadTask)
        }
    }
    
    func uploadPicture(root: String, ID: String, image: UIImage, picRef: String) {
        let ref = storageRef.child(root).child(ID).child(picRef)
        
        guard let uploadData = image.jpegData(compressionQuality: 0.8)  else{
            return
        }
        
        // Upload image to firebase
        _ = ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
            if error != nil{
                print(error)
                return
            }
            print("Image successfully uploaded")
            
        })
    }
    
    
    //Func to observe error cases while uploading image files, Ref: https://firebase.google.com/docs/storage/ios/upload-files
    func observeUploadTaskFailureCases(uploadTask : StorageUploadTask){
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    NSLog("File doesn't exist")
                    break
                case .unauthorized:
                    NSLog("User doesn't have permission to access file")
                    break
                case .cancelled:
                    NSLog("User canceled the upload")
                    break
                case .unknown:
                    NSLog("Unknown error occurred, inspect the server response")
                    break
                default:
                    NSLog("A separate error occurred, This is a good place to retry the upload.")
                    break
                }
            }
        }
    }
    
    func updateProfile(picture: UIImage, completion: @escaping (String) -> ()){
        var data = Data()
        data = picture.pngData()!
        let reference = getProfilePictureReference()
        let metadata  = StorageMetadata()
        metadata.contentType = "image/png"
        reference.child("profilePicture.png").putData(data, metadata: metadata){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                //store path
                completion((metaData?.path)!)
            }
            
        }
    }
    
    func loadProfilePicture(picRef: String, completion: @escaping (UIImage) -> ()){
        let reference = getProfilePictureReference().child(picRef)
        print("ref \(reference)")
        
        reference.getData(maxSize: 15 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error.localizedDescription)
            } else {
                completion(UIImage(data: data!)!)
            }
        }
    }
    
    func loadProfilePicture(userID: String, picRef: String, completion: @escaping (UIImage) -> ()){
        let reference = getProfilePictureReference().child(picRef)
        print("ref \(reference)")
        
        reference.getData(maxSize: 15 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error.localizedDescription)
            } else {
                completion(UIImage(data: data!)!)
            }
        }
    }
}
