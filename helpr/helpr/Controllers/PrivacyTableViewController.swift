//
//  PrivacyTableViewController.swift
//  helpr
//
//  Created by adrian.parcioaga and walter.alvarez on 2018-11-19.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit

class PrivacyTableViewController: UITableViewController {
    
    //MARK: Toggles
    
    // Notifications
    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var smsSwitch: UISwitch!
    //Notify Me When...
    @IBOutlet weak var newReviewSwitch: UISwitch!
    @IBOutlet weak var bidAcceptedSwitch: UISwitch!
    @IBOutlet weak var bidDeclinedSwitch: UISwitch!
    @IBOutlet weak var postUploadSwitch: UISwitch!
    @IBOutlet weak var newMessageSwitch: UISwitch!
    @IBOutlet weak var newRatingSwitch: UISwitch!
    @IBOutlet weak var newBidSwitch: UISwitch!
    //Data Sharing
    @IBOutlet weak var featuredReviewsSwitch: UISwitch!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var profilePicSwitch: UISwitch!
    @IBOutlet weak var skillsSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 7
        case 2:
            return 4
        default:
            print("But why?")
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = UIColor.init(named: "RoyalPurple")
        }
    }
}
