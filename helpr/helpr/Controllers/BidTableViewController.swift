//
//  BidTableViewController.swift
//  helpr
//
//  Created by Walter Alvarez on 2019-03-05.
//  Copyright © 2019 ryan.konynenbelt. All rights reserved.
//

import UIKit
import Firebase

class BidTableViewController: UITableViewController {
    var job: Job?
    @IBOutlet var bidTable: UITableView!
    @IBOutlet weak var tfBidAmt: UITextField!
    @IBOutlet weak var scRate: UISegmentedControl!
    @IBOutlet weak var tfCompTime: UITextField!
    @IBOutlet weak var scTimeUnit: UISegmentedControl!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnPlaceBid: UIBarButtonItem!
    
    let locale = Locale.current
    var currencySymbol = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let jobNumber = job?.information.id else {return}
        navigationItem.title = "Bid on Job # \(jobNumber)"
        currencySymbol = locale.currencySymbol!
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    //Cancel button in nav bar selected
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Place bid button in nav bar selected
    //to do: create bid
    @IBAction func btnPlaceBid(_ sender: Any) {
        let userID = Auth.auth().currentUser?.uid
        let database = DatabaseHelper()
        let bidAmtStr = tfBidAmt.text?.split(separator: Character(currencySymbol), maxSplits: 1, omittingEmptySubsequences: true)
        let bidAmount = Float(bidAmtStr![0])
        var rateType = ""
        switch (scRate.selectedSegmentIndex) {
        case 0:
            rateType = "hourly"
        default:
            rateType = ""
        }
        let timeEstStr = tfCompTime.text!
        let timeEstimate = Float(timeEstStr)
        var timeUnit = ""
        switch (scTimeUnit.selectedSegmentIndex) {
        case 0:
            timeUnit = "minutes"
        case 1:
            timeUnit = "hours"
        default:
            timeUnit = "days"
        }
        let chatID = NSUUID().uuidString
        database.createBid(bidAmt: bidAmount!, rateType: rateType, timeEst: timeEstimate!, timeUnit: timeUnit, job: job!, userID: userID!, chatID: chatID) { (err) in
            if err != nil {
                print(err!._code)
            } else {
                print("bid succesfully added")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //User begins editing Bid Amount text field (prepends string with $)
    @IBAction func bidAmtBegin(_ sender: Any) {
        if (tfBidAmt.text == "") {
            tfBidAmt.text = currencySymbol
        }
    }
    
    //User stops editing Bid Amount text field (removed $ if no other input logged)
    @IBAction func bidAmtEnd(_ sender: Any) {
        if (tfBidAmt.text == currencySymbol) {
            tfBidAmt.text = ""
        }
    }
    
    //while user editing, checks if both bid amount and time estimate are non empty values
    //if that's the case, enable Place Bid nav button
    @IBAction func tfChanged(_ sender: Any) {
        if (tfBidAmt.text != "" && tfBidAmt.text != currencySymbol && tfCompTime.text != "") {
            btnPlaceBid.isEnabled = true
        }
        else {
            btnPlaceBid.isEnabled = false
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

}
