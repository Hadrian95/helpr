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
    
    func storeMessage(senderID: String, chatID: String, content: String, senderName: String, timestamp: Date) {
        // create the first message exchanged within newly created chat document
        let messageID = NSUUID().uuidString
        docRef = db.collection("chats").document(chatID).collection("messages").document(messageID)
        docRef.setData(["content" : content, "created" : timestamp, "senderID" : senderID, "senderName" : senderName]) { (error) in
            if error != nil {
                print("Error adding data to chat messages collection")
            }else{
                print("Data has been successfully added to chat messages collection")
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
    
    func createBid(msgType: Int, bidAmt: Float, rateType: String, timeEst: Float, timeUnit: String, job: Job, partnerID: String, userID: String, chatID: String, completion: @escaping (Error?) -> ()) {
        
        let bidInfo = ["active" : true, "bidPostedTime": Date(), "bid" : ["amount" : bidAmt, "rateType": rateType], "timeEstimate" : ["amount" : timeEst, "unit" : timeUnit]] as [String : Any]
        
        // create a chat document for this bid
        docRef = db.collection("chats").document(chatID)
        docRef.setData(["accepted" : false, "job": job.information.id, "jobFirebaseID": job.information.firebaseID]) { (error) in
            if error != nil {
                print("Error adding data to chat doc")
            }else{
                print("Data has been successfully added to chat doc")
            }
        }
        
        // create the message exchanged within newly created chat document
        let messageID = NSUUID().uuidString
        
        var bidMsg = ""
        var content = ""
        
        switch msgType {
        case 0: // placing a bid
            bidMsg = "Hi! I can do your posted job (\"" + job.information.title + "\") for $" + String(bidAmt) + " " + rateType
            content = bidMsg + " and it would take me about " + String(timeEst) + " " + timeUnit
        case 1: // countering a bid
            if (userID == job.information.email) {
                bidMsg = "Can you do it for $" + String(bidAmt) + " " + rateType
                content = bidMsg + " in " + String(timeEst) + " " + timeUnit
            } else {
                bidMsg = "I will do it for $" + String(bidAmt) + " " + rateType
                content = bidMsg + " and it would take me about " + String(timeEst) + " " + timeUnit
            }
        default: // accepted a bid?
            bidMsg = "accepted a bid"
            content = bidMsg + "!"
        }
        
        
        docRef = db.collection("chats").document(chatID).collection("messages").document(messageID)
        docRef.setData(["content" : content, "created" : Date(), "senderID" : userID, "senderName" : UserProfile.name.components(separatedBy: " ")[0]]) { (error) in
            if error != nil {
                print("Error adding data to chat messages collection")
            }else{
                print("Data has been successfully added to chat messages collection")
            }
        }
        
        // add bidder to "bidders" collection for job being bid on
        let bidID = NSUUID().uuidString
        colRef = db.collection("jobs").document(job.information.firebaseID).collection("bidders")
        if (userID != job.information.email) {
            docRef = colRef.document(userID).collection("bids").document(bidID)
            docRef.setData(bidInfo) { (error) in
                if error != nil {
                    print("Error adding data to jobs bidders collection")
                    completion(nil)
                }else{
                    print("Data has been successfully added to jobs bidders collection!")
                    completion(error)
                }
            }
        } else {
            docRef = colRef.document(partnerID).collection("bids").document(bidID)
            docRef.setData(bidInfo) { (error) in
                if error != nil {
                    print("Error adding data to jobs bidders collection")
                    completion(nil)
                }else{
                    print("Data has been successfully added to jobs bidders collection!")
                    completion(error)
                }
            }
        }
        
        // get posters profile picture
        // ****** job.information.email is actually poster id, needs to be refactored, thanks Helm ****** //
        docRef = db.collection("users").document(job.information.email) // email is actually poster id, needs to be refactored
        docRef.getDocument() { (document, error) in
            if let document = document, document.exists {
                let posterName = document.data()?["name"] as! String
                let posterPicRef = document.data()?["profilePic"] as! String
                
                // create conversation reference in bidder's conversations log
                self.db.collection("users").document(userID).collection("conversations").whereField("chatID", isEqualTo: chatID).getDocuments() { (querySnapshot, error) in
                    if (querySnapshot?.isEmpty)! {
                        print("Error getting bidder conversation doc")
                        let bidderDocRef = self.db.collection("users").document(userID).collection("conversations").document()
                        bidderDocRef.setData(["active" : true, "chatID" : chatID, "chatPartnerName" : posterName.components(separatedBy: " ")[0], "chatPartnerID" : job.information.email, "chatPartnerPicRef" : posterPicRef, "jobID" : job.information.id, "jobFirebaseID": job.information.firebaseID]) { (error) in
                            if error != nil {
                                print("Error adding data to bidder's conversations collection")
                                completion(nil)
                            }else{
                                print("Data has been successfully added to bidder's conversations collection!")
                                completion(error)
                            }
                        }
                    } else {
                        for document in (querySnapshot?.documents)! {
                            let bidderDocRef = self.db.collection("users").document(userID).collection("conversations").document(document.documentID)
                            bidderDocRef.setData(["active" : true], merge: true)
                        }
                    }
                }
            } else {
                print("User who posted job does not exist")
            }
        }
        
        // create conversation reference in poster's conversations log
        self.db.collection("users").document(job.information.email).collection("conversations").whereField("chatID", isEqualTo: chatID).getDocuments() { (querySnapshot, error) in
            if (querySnapshot?.isEmpty)! {
                self.docRef = self.db.collection("users").document(job.information.email).collection("conversations").document()
                self.docRef.setData(["active" : true, "chatID" : chatID, "chatPartnerName": UserProfile.name.components(separatedBy: " ")[0], "chatPartnerID" : userID, "chatPartnerPicRef" : UserProfile.profilePicRef, "jobID": job.information.id, "jobFirebaseID": job.information.firebaseID]) { (error) in
                    if error != nil {
                        print("Error adding data to poster's conversations collection")
                        completion(nil)
                    }else{
                        print("Data has been successfully added to poster's conversations collection!")
                        completion(error)
                    }
                }
            } else {
                for document in (querySnapshot?.documents)! {
                    let docRef = self.db.collection("users").document(job.information.email).collection("conversations").document(document.documentID)
                    docRef.setData(["active" : true], merge: true)
                }
            }
        }
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

    // get current user
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
    
    // get user with known id, can probably consolidate these two getUser methods into one and refactor
    func getUser(uID: String, completion: @escaping (UserInfo?) -> () ) {
        let user = UserInfo()
        docRef = db.collection("users").document(uID)
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
                        address: document.data()["address"]! as! [String : String],
                        location: document.data()["location"]! as! GeoPoint,
                        anonLocation: document.data()["anonLocation"]! as! GeoPoint,
                        distance: 0,
                        postalCode: "T3A 1B6",
                        postedTime: document.data()["postedTime"]! as! Date,
                        email: document.data()["posterID"]! as! String,
                        id: document.data()["id"]! as! Int)
//                    let storage = StorageHelper()
//                    storage.loadImages(job: job!)
                    jobs.append(job!)
                }
                completion(jobs)
            }
        }
    }

    // load one job at a time, to be called when a new post has been added to database
    func getJob(jobID: String, completion: @escaping (Job) -> () )  {
        var job : Job!

        print("trying to grab document: " + jobID)

        db.collection("jobs").document(jobID).getDocument { (document, err) in
            if let document = document, document.exists {
                job = Job (
                    title: document.data()?["title"]! as! String,
                    category: document.data()?["category"]! as! String,
                    description: document.data()?["description"]! as! String,
                    pictureURLs: document.data()?["pictureURLs"]! as! [String],
                    tags: ["#iPhone", "#Swift", "#Apple"],
                    address: document.data()?["address"]! as! [String : String],
                    location: document.data()?["location"]! as! GeoPoint,
                    anonLocation: document.data()?["anonLocation"]! as! GeoPoint,
                    distance: 0,
                    postalCode: "T3A 1B6",
                    postedTime: document.data()?["postedTime"]! as! Date,
                    email: document.data()?["posterID"]! as! String,
                    firebaseID: document.documentID,
                    id: document.data()?["id"]! as! Int)
//                let storage = StorageHelper()
//                storage.loadImages(job: job!)
                completion(job!)
            } else {
                print("Job document does not exist")
            }
        }
    }
    
    func getBidAmt(chatID: String, chatPartnerID: String, completion: @escaping (String, Bool, Bid) -> ()) {
        
        //used for converting float to monetary value, formatted and in current locale currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        var accepted = false
        var bidObj: Bid?
        
        db.collection("chats").document(chatID).getDocument() { (document, error) in
            if let document = document, document.exists {
                let jobFBID = document.data()?["jobFirebaseID"] as! String
                accepted = document.data()?["accepted"] as! Bool
                var bidStr = ""
                var userID = Auth.auth().currentUser?.uid
                self.db.collection("jobs").document(jobFBID).getDocument() { (document, error) in
                    if let document = document, document.exists {
                        let posterID = document.data()?["posterID"] as! String
                        
                        // I am the poster of the job, bidder document will be under chat partner's id
                        if (posterID == userID) {
                            self.db.collection("jobs").document(jobFBID).collection("bidders").document(chatPartnerID).collection("bids").whereField("active", isEqualTo: true).order(by: "bidPostedTime", descending: true).limit(to: 1).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print("Error getting bid docs: \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            let bid = document.data()["bid"] as! [String: Any]
                                            let timeEstimate = document.data()["timeEstimate"] as! [String: Any]
                                            let amt = bid["amount"] as! Float
                                            let rate = bid["rateType"] as! String
                                            let time = timeEstimate["amount"] as! Float
                                            let timeRate = timeEstimate["unit"] as! String
                                            
                                            bidObj = Bid(amount: amt, rateType: rate, timeEst: time, units: timeRate)
                                            
                                            switch (rate) {
                                            case "hourly":
                                                if let formattedBidAmt = formatter.string(from: amt as NSNumber) {
                                                    bidStr = "\(formattedBidAmt)/hr"
                                                }
                                                else {
                                                    bidStr = "undefined"
                                                }
                                                break;
                                            default:
                                                bidStr = formatter.string(from: amt as NSNumber) ?? "undefined"
                                            }
                                        }
                                        completion(bidStr, accepted, bidObj!)
                                    }
                                }
                            }
                        // I am the bidder, bidder document will be stored under my id
                        else {
                            self.db.collection("jobs").document(jobFBID).collection("bidders").document(userID!).collection("bids").whereField("active", isEqualTo: true).order(by: "bidPostedTime", descending: true).limit(to: 1).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting bid docs: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        let bid = document.data()["bid"] as! [String: Any]
                                        let timeEstimate = document.data()["timeEstimate"] as! [String: Any]
                                        let amt = bid["amount"] as! Float
                                        let rate = bid["rateType"] as! String
                                        let time = timeEstimate["amount"] as! Float
                                        let timeRate = timeEstimate["unit"] as! String
                                        
                                        bidObj = Bid(amount: amt, rateType: rate, timeEst: time, units: timeRate)
                                        
                                        switch (rate) {
                                        case "hourly":
                                            if let formattedBidAmt = formatter.string(from: amt as NSNumber) {
                                                bidStr = "\(formattedBidAmt)/hr"
                                            }
                                            else {
                                                bidStr = "undefined"
                                            }
                                            break;
                                        default:
                                            bidStr = formatter.string(from: amt as NSNumber) ?? "undefined"
                                        }
                                    }
                                completion(bidStr, accepted, bidObj!)
                                }
                            }
                        }
                    } else {
                        print("Job document does not exist")
                    }
                }
            } else {
                print("Chat document does not exist")
            }
        }
    }
    
    // get latest message info once chat id has been parsed from user's conversations collection
    func getMsgPreview(chatID: String, completion: @escaping (String, Date, String) -> ()) {
        
        print("trying to grab chat message preview for chat id: " + chatID)
        
        self.db.collection("chats").document(chatID).collection("messages").order(by: "created", descending: true).limit(to: 1).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting message preview: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let content = document.data()["content"] as! String
                    let created = document.data()["created"] as! Date
                    let senderName = document.data()["senderName"] as! String
                    completion(content, created, senderName)
                }
            }
        }
    }
    
    func acceptedJob(jobID: String, chatID: String, helprID: String) {
        // turn chat to accepted so users can commmunicate fully
        db.collection("chats").document(chatID).setData(["accepted": true], merge: true)
        
        // add accepted helpr to job
        db.collection("jobs").document(jobID).collection("helprs").document(helprID).setData(["acceptedOn": Date()])
        
        // add job to user's records
        let docRef = db.collection("users").document(helprID).collection("acceptedJobs").document(jobID)
        docRef.setData(["completed": false, "acceptedOn" : Date()])
    }
    
    func rejectBid(userID: String, partnerID: String, chatID: String, jobID: String) {
        db.collection("users").document(userID).collection("conversations").whereField("chatID", isEqualTo: chatID).getDocuments() { (querySnapshot, error) in
            if ((querySnapshot?.isEmpty)!) {
                // do nothing
            } else {
                for document in querySnapshot!.documents {
                    self.db.collection("users").document(userID).collection("conversations").document(document.documentID).setData(["active": false], merge: true)
                }
            }
        }
        db.collection("users").document(partnerID).collection("conversations").whereField("chatID", isEqualTo: chatID).getDocuments() { (querySnapshot, error) in
            if ((querySnapshot?.isEmpty)!) {
                // do nothing
            } else {
                for document in querySnapshot!.documents {
                    self.db.collection("users").document(partnerID).collection("conversations").document(document.documentID).setData(["active": false], merge: true)
                }
            }
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
