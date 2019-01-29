//
//  StorageHelper.swift
//  helpr
//
//  Created by Hilmi Abou-Saleh on 2018-11-25.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
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
        return storageRef.child("jobPictures").child(job.information.id)
    }
    
    func saveImages(job: Job, imagesArray : [UIImage], createJob: Bool){
        job.pictureData = imagesArray
        uploadImages(jobID: job.information.id, imagesArray : imagesArray){ (uploadedImageUrlsArray) in
            job.information.pictures = uploadedImageUrlsArray
            if createJob {
                let database = DatabaseHelper()
                database.writeJob(job: job)
            }
        }
    }
    
    
    
    
    func loadImages(job: Job){
        if job.information.pictures.count < 1 { return }
        
        downloadImages(jobID: job.information.id, images: job.information.pictures as! [String]){ downloadedImages in
            job.pictureData = downloadedImages
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
    
    func uploadImages(jobID: String, imagesArray : [UIImage], completionHandler: @escaping ([String]) -> ()){
        
        var uploadedImageUrlsArray = [String]()
        var uploadCount = 0
        let imagesCount = imagesArray.count
        
        for image in imagesArray{
            
            let imageName = NSUUID().uuidString // Unique string to reference image
            
            //Create storage reference for image
            let ref = storageRef.child("jobPictures").child(jobID).child("\(imageName).png")
            
            
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
    func loadProfilePicture(completion: @escaping (UIImage) -> ()){
        let reference = getProfilePictureReference().child("profilePicture.png")
        let image: UIImage? = FileHelpers.load(path: reference.fullPath)
        if  image == nil {
            reference.getData(maxSize: 15 * 2048 * 2048) { data, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    print(error.localizedDescription)
                } else {
                    //let path = FileHelpers.save(image: UIImage(data: data!)!, path: reference.fullPath)
                    completion(UIImage(data: data!)!)
                }
            }
        }else{
            completion(image!)
        }
        
    }

    
}
