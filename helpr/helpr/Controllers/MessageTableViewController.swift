//
//  MessageTableViewController.swift
//  helpr
//
//  Created by Critical on 2019-02-05.
//  Copyright © 2019 ryan.konynenbelt. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class MessageTableViewController: UITableViewController {
    var mPreviews = [MessagePreview]()
    var db = Firestore.firestore()
    var database = DatabaseHelper()
    var userID = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPreviews(notification:)), name: NSNotification.Name(rawValue: "reloadMessagePreviews"), object: nil)
        
        loadSampleMessagePreviews()
        
        db.collection("users").document(userID!).collection("conversations").order(by: "jobID", descending: true)
            .addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching conversations snapshots: \(String(describing: error))")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let active = diff.document.data()["active"] as! Bool
                    if (active) {
                        var msgPreview = MessagePreview()
                        
                        let chatID = diff.document.data()["chatID"] as! String
                        let partnerName = diff.document.data()["chatPartnerName"] as! String
                        let chatPartnerID = diff.document.data()["chatPartnerID"] as! String
                        let partnerPicRef = diff.document.data()["chatPartnerPicRef"] as! String
                        
                        msgPreview?.partnerID = chatPartnerID
                        msgPreview?.partnerPicRef = partnerPicRef
                        msgPreview?.senderName = partnerName
                        
                        DispatchQueue.main.async {
                            self.database.getBidAmt(chatID: chatID, chatPartnerID: chatPartnerID) { (bid) in
                                msgPreview?.bidAmt = bid
                                self.database.getMsgPreview(chatID: chatID) { (content, created, senderName) in
                                    msgPreview?.mPreview = content
                                    msgPreview?.mTime =  created.timeAgoSinceDate(currentDate: Date(), numericDates: true)
                                    
                                    self.mPreviews.append(msgPreview!)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadMessagePreviews"), object: nil)
                                }
                            }
                        }
                    }
                }
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // reload on new message preview added
    @objc func reloadPreviews(notification: NSNotification){
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mPreviews.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "MessagePreviewTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageTableViewCell else {
            fatalError("The dequeued cell is not an instance of HomeTableVieCell")
        }
        
        let preview : MessagePreview
        preview = mPreviews[indexPath.row]
        
        cell.lblName.text = preview.senderName
        cell.lblMsgPreview.text = preview.mPreview
        
        if (preview.picture != nil) {
            cell.ivProfilePic.image = preview.picture
        } else {
            // get other user's image from database, use default picture if an error occurs
            let storageRef = Storage.storage().reference()
            let ref = storageRef.child("profilePictures").child(preview.partnerID).child(preview.partnerPicRef)
            let phImage = UIImage(named: "jobDefault.png")
            cell.ivProfilePic.sd_setImage(with: ref, placeholderImage: phImage)
        }
        
        cell.lblBidAmt.text = preview.bidAmt
        cell.lblMsgTime.text = preview.mTime

        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
            
        case "showUserProfile":
            guard let userProfileVC = segue.destination as? ProfileViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedPreviewCell = sender as? MessageTableViewCell else {
                fatalError("Unexpected message sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedPreviewCell) else {
                fatalError("The selected message cell is not being displayed by the table")
            }
            
            let uID = mPreviews[indexPath.row].partnerID
            userProfileVC.userID = uID
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    private func loadSampleMessagePreviews() {
        guard let m1 = MessagePreview(name: "Walter", preview: "Adrian makes a pretty good point, I would listen to him on this. You won't be disappointed.", pic: UIImage(named: "Walter")!, bid: "$35/hr", time: "5 mins") else {
            fatalError("Unable to instantiate message1")
        }
        
        guard let m2 = MessagePreview(name: "Adrian", preview: "Wow, look at all this information you can see hardcoded into this view! Truly inspiring, deserves investment, much start-up", pic: UIImage(named: "Adrian")!, bid: "$25/hr", time: "9 mins") else {
            fatalError("Unable to instantiate message1")
        }
        
        guard let m3 = MessagePreview(name: "Christian", preview: "I'm in the Netherlands right now, working hard in spirit, Adrian and Walter are by far my superiors.", pic: UIImage(named: "Christian")!, bid: "$5/hr", time: "23 mins") else {
            fatalError("Unable to instantiate message1")
        }
        
        guard let m4 = MessagePreview(name: "Iker", preview: "Happy to be here, new kid on the block, I'm in business so automatically better than everyone.", pic: UIImage(named: "Iker")!, bid: "$50/hr", time: "45 mins") else {
            fatalError("Unable to instantiate message1")
        }
        
        mPreviews += [m1, m2, m3, m4]
    }
}
