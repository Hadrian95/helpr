//
//  MessageTableViewController.swift
//  helpr
//
//  Created by Critical on 2019-02-05.
//  Copyright © 2019 ryan.konynenbelt. All rights reserved.
//

import UIKit

class MessageTableViewController: UITableViewController {
    var mPreviews = [MessagePreview]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSampleMessagePreviews()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        cell.ivProfilePic.image = preview.picture
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
