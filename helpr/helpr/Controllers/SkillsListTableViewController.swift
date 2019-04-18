//
//  SkillsListTableViewController.swift
//  helpr
//
//  Created by Walter Alvarez on 2019-03-07.
//  Copyright © 2019 helpr. All rights reserved.
//

import UIKit

class SkillsListTableViewController: UITableViewController {

    var skillsList = UserProfile.skills
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skillsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.imageView?.image = UIImage(named: "bronzeMedal")
        cell.imageView?.contentMode = .scaleAspectFit
        cell.textLabel?.text = skillsList[indexPath.row]

        return cell
    }
}
