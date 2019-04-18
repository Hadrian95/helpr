//
//  CategoriesTableViewController.swift
//  helpr
//
//  Created by walter.alvarez on 2018-11-23.
//  Copyright © 2018 helpr. All rights reserved.
//
// list of categories offered by helpr
// TODO: pull categories list from DB master

import UIKit

class CategoriesTableViewController: UITableViewController {

    var categories = ["Automotive", "Cleaning", "Design", "Development", "Furniture Assembly", "Minor Repair", "Technology", "Tech Repair", "Tutoring", "Web Design"]
    var sortedCategories = [""]
    static var selectedCellText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sortedCategories can be removed once category list is obtained from DB
        sortedCategories = categories.sorted()
        self.clearsSelectionOnViewWillAppear = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedCategories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableViewCell", for: indexPath) as? CategoriesTableViewCell else {
            fatalError("The dequeued cell is not an instance of CategoriesTableViewcell.")
        }
        
        // Configure the cell...
        cell.lCategoryName.text = sortedCategories[indexPath.row]
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("You selected cell number: \(indexPath.row)!")
        
        CategoriesTableViewController.selectedCellText = sortedCategories[indexPath.row]
        _ = navigationController?.popViewController(animated: true)
    }
}
