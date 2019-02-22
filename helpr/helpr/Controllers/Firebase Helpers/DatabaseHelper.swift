//
//  Database.swift
//  helpr
//
//  Created by Hilmi Abou-Saleh on 2018-11-22.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import Firebase
import CodableFirebase

class DatabaseHelper {
    var ref: DatabaseReference!
    var storage = StorageHelper()
    var docRef: DocumentReference!
    var colRef: CollectionReference!
    var db: Firestore!
    var jobs: [Job]
    init() {
        ref = Database.database().reference()
        db = Firestore.firestore()
        jobs = [Job]()
    }
    
    func createUser(email: String, password: String, completion: @escaping (Error?) -> ()){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil {
                print("Creating user: " + (user?.user.email)!)
                completion(nil)
            }else{
                print("Cannot create account" + error.debugDescription)
                completion(error)
            }
        }
    }
    
    func addJobInformation(dataToSave: [String: Any], tags: [String], jobID: String, completion: @escaping (Error?) -> ()) {
        let userID = dataToSave["posterID"] as! String
        
        docRef = db.collection("jobs").document(jobID)
        docRef.setData(dataToSave) { (error) in
            if error != nil {
                print("Error adding data to jobs collection")
                completion(nil)
            }else{
                print("Data has been successfully added!")
                completion(error)
            }
        }
        
        colRef = db.collection("jobs").document(jobID).collection("tags")
        for tag in tags {
            docRef = colRef.document(tag)
        }
        
        colRef = db.collection("users").document(userID).collection("posts")
        docRef = colRef.document(jobID)
        docRef.setData(["completed": false])
    }
    
    
    func addUserInformation(dataToSave: [String: Any], photoURL: String?, completion: @escaping (Error?) -> ()) {
        let userID = Auth.auth().currentUser?.uid
        docRef = db.collection("users").document(userID!)
        docRef.setData(dataToSave) { (error) in
            if error != nil {
                print("Error adding data to users collection")
                completion(nil)
            }else{
                print("Data has been successfully added!")
                completion(error)
            }
        }
    }
    
    func getUser(completion: @escaping (UserInfo?) -> () ) {
        let userID = Auth.auth().currentUser?.uid
        let user = UserInfo()
        docRef = db.collection("users").document(userID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //let userData = document.data().map(String.init(describing:)) ?? "nil"
                user.name = document.data()?["name"]! as! String
                user.email = document.data()?["email"]! as! String
                user.skills = document.data()?["skills"] as! [String]
                user.picRef = document.data()?["profilePic"]! as! String
                completion(user)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // load multiple jobs on initial startup
    func getJobs(completion: @escaping ([Job]) -> () )  {
        var jobs = [Job]()
        
        db.collection("jobs").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let job = Job (
                        title: document.data()["title"]! as! String,
                        category: document.data()["category"]! as! String,
                        description: document.data()["description"]! as! String,
                        pictureURLs: document.data()["pictureURLs"]! as! [String],
                        tags: ["#iPhone", "#Swift", "#Apple"],
                        distance: 0,
                        postalCode: "T3A 1B6",
                        postedTime: document.data()["postedTime"]! as! Date,
                        email: (Auth.auth().currentUser?.email)!)
                    //let storage = StorageHelper()
                    //storage.loadImages(job: job!)
                    jobs.append(job!)
                }
                completion(jobs)
            }
        }
    }
    
    // load one job at a time, to be called when a new post has been added to database
    func getJob(jobID: String, completion: @escaping (Job) -> () )  {
        var job : Job!
        
        db.collection("jobs").document(jobID).getDocument { (document, err) in
            if let document = document, document.exists {
                job = Job (
                    title: document.data()?["title"]! as! String,
                    category: document.data()?["category"]! as! String,
                    description: document.data()?["description"]! as! String,
                    pictureURLs: document.data()?["pictureURLs"]! as! [String],
                    tags: ["#iPhone", "#Swift", "#Apple"],
                    distance: 0,
                    postalCode: "T3A 1B6",
                    postedTime: document.data()?["postedTime"]! as! Date,
                    email: (Auth.auth().currentUser?.email)!,
                    id: document.documentID)
                //let storage = StorageHelper()
                //storage.loadImages(job: job!)
            } else {
                print("Job document does not exist")
            }
            
            completion(job!)
        }
    }
    
    func readJobs(completion: @escaping ([Job]) -> ()){
        var jobs = [Job]()
        ref.child("jobs").queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                if snap.exists() {
                    if let dict = snap.value as? [String: Any] {
                        let jobInformation = try! FirebaseDecoder().decode(JobInformation.self, from: dict)
                        let job = Job(jobInformation: jobInformation)
                        let storage = StorageHelper()
                        storage.loadImages(job: job!)
                        jobs.append(job!)
                    }
                }
            }
            completion(jobs)
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
}
