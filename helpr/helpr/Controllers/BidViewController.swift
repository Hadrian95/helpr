//
//  BidTableViewController.swift
//  helpr
//
//  Created by Walter Alvarez on 2019-03-05.
//  Copyright © 2019 ryan.konynenbelt. All rights reserved.
//

import UIKit
import Firebase

class BidViewController: UIViewController {
    var job: Job?
    var bid: Bid?
    var chatID: String?
    var partnerID: String?
    var db = Firestore.firestore()
    var database = DatabaseHelper()
    
    @IBOutlet weak var tfBidAmt: UITextField!
    @IBOutlet weak var scRate: UISegmentedControl!
    @IBOutlet weak var tfCompTime: UITextField!
    @IBOutlet weak var scTimeUnit: UISegmentedControl!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnPlaceBid: UIBarButtonItem!
    
    
    let locale = Locale.current
    var currencySymbol = ""
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        let myString = "Accept"
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 19.0) ]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        
        button.setAttributedTitle(myAttrString, for: UIControl.State())
        button.backgroundColor = UIColor.green
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var counterButton: UIButton = {
        let button = UIButton(type: .system)
        let myString = "Counter"
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 19.0) ]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        
        button.setAttributedTitle(myAttrString, for: UIControl.State())
        button.backgroundColor = UIColor.yellow
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var rejectButton: UIButton = {
        let button = UIButton(type: .system)
        let myString = "Reject"
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 19.0) ]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        
        button.setAttributedTitle(myAttrString, for: UIControl.State())
        button.backgroundColor = UIColor.red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let jobNumber = job?.information.id else {return}
        navigationItem.title = "Bid on Job # \(jobNumber)"
        currencySymbol = locale.currencySymbol!
        if (chatID != nil) {
            self.navigationItem.rightBarButtonItem = nil
            tfBidAmt.text = "$" + (bid?.amt?.description)!
            switch (bid?.rate) {
            case "hourly":
                scRate.selectedSegmentIndex = 0
                break
            default:
                scRate.selectedSegmentIndex = 1
            }
            tfCompTime.text = bid?.time?.description
            switch (bid?.timeUnits) {
            case "minutes":
                scTimeUnit.selectedSegmentIndex = 0
                break
            case "hours":
                scTimeUnit.selectedSegmentIndex = 1
                break
            default:
                scRate.selectedSegmentIndex = 2
            }
            addBidActionsSubview()
        }
    }
    
    func addBidActionsSubview() {
        let customActionBar = UIView()
        customActionBar.backgroundColor = UIColor.clear
        customActionBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(customActionBar)
        
        var thirdOfScreen = view.frame.width / 3
        //ios9 constraint anchors
        //x,y,w,h
        customActionBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        customActionBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        customActionBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        customActionBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        customActionBar.addSubview(acceptButton)
        
        acceptButton.leftAnchor.constraint(equalTo: customActionBar.leftAnchor).isActive = true
        acceptButton.centerYAnchor.constraint(equalTo: customActionBar.centerYAnchor).isActive = true
        acceptButton.widthAnchor.constraint(equalToConstant: thirdOfScreen).isActive = true
        acceptButton.heightAnchor.constraint(equalTo: customActionBar.heightAnchor).isActive = true
        acceptButton.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        
        customActionBar.addSubview(counterButton)
        
        counterButton.leftAnchor.constraint(equalTo: acceptButton.rightAnchor).isActive = true
        counterButton.centerYAnchor.constraint(equalTo: customActionBar.centerYAnchor).isActive = true
        counterButton.widthAnchor.constraint(equalToConstant: thirdOfScreen).isActive = true
        counterButton.heightAnchor.constraint(equalTo: customActionBar.heightAnchor).isActive = true
        counterButton.addTarget(self, action: #selector(handleCounter), for: .touchUpInside)
        
        customActionBar.addSubview(rejectButton)
        
        rejectButton.rightAnchor.constraint(equalTo: customActionBar.rightAnchor).isActive = true
        rejectButton.centerYAnchor.constraint(equalTo: customActionBar.centerYAnchor).isActive = true
        rejectButton.widthAnchor.constraint(equalToConstant: thirdOfScreen).isActive = true
        rejectButton.heightAnchor.constraint(equalTo: customActionBar.heightAnchor).isActive = true
        rejectButton.addTarget(self, action: #selector(handleReject), for: .touchUpInside)
    }
    
    @objc func handleAccept() {
        // current user is the bidder
        if (partnerID == job?.information.email) {
            database.acceptedJob(jobID: (job?.information.firebaseID)!, chatID: chatID!, helprID: (Auth.auth().currentUser?.uid)!)
        }
        // current user is the job poster
        else {
            database.acceptedJob(jobID: (job?.information.firebaseID)!, chatID: chatID!, helprID: partnerID!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCounter() {
        btnPlaceBid(counterButton)
    }
    
    @objc func handleReject() {
        print("Reject")
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
        
        if (chatID != nil) {
            database.createBid(msgType: 1, bidAmt: bidAmount!, rateType: rateType, timeEst: timeEstimate!, timeUnit: timeUnit, job: job!,partnerID: partnerID!, userID: userID!, chatID: self.chatID!) { (err) in
                if err != nil {
                    print(err!._code)
                } else {
                    print("bid succesfully added")
                }
            }
        } else {
            db.collection("users").document(userID!).collection("conversations").whereField("jobID", isEqualTo: job?.information.id).getDocuments() { (querySnapshot, error) in
                if ((querySnapshot?.isEmpty)!) {
                    print("conversation does not exist already")
                    self.chatID = NSUUID().uuidString
                }
                else {
                    for document in (querySnapshot?.documents)! {
                        self.chatID = document.data()["chatID"] as? String
                    }
                }
                database.createBid(msgType: 0, bidAmt: bidAmount!, rateType: rateType, timeEst: timeEstimate!, timeUnit: timeUnit, job: self.job!, partnerID: "", userID: userID!, chatID: self.chatID!) { (err) in
                    if err != nil {
                        print(err!._code)
                    } else {
                        print("bid succesfully added")
                    }
                }
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
        if (btnPlaceBid != nil) {
            if (tfBidAmt.text != "" && tfBidAmt.text != currencySymbol && tfCompTime.text != "") {
                btnPlaceBid.isEnabled = true
            }
            else {
                btnPlaceBid.isEnabled = false
            }
        }
    }
}
