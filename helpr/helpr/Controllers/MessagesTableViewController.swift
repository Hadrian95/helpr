//
//  MessagesTableViewController.swift
//  helpr
//
//  Created by adrian.parcioaga on 2018-10-30.
//  Implemented by madebyhilmi on 2018-11-04.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit
import os.log
class MessagesTableViewController: UITableViewController, UISearchResultsUpdating {

    
    //MARK: Properties
    var filteredJobs = [Job]()
    var isPurple = Bool()

    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredJobs = loadMyPosts()
        tableView.reloadData()

        isPurple = false

        
//        searchController.searchResultsUpdater = self
//        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.searchBar.backgroundColor = UIColor(named: "RoyalPurple")
//        tableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = true

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering() {
            return filteredJobs.count
        }
        return filteredJobs.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MyPostsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyPostsTableViewCell else {
            fatalError("The dequeued cell is not an instance of MyPostsTableViewCell")
        }
        
        // fetches the appropriate job for the data source layout
        let job : Job
        if isFiltering() {
            job = filteredJobs[indexPath.row]
        } else {
            job = filteredJobs[indexPath.row]
        }
        
        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 3.0
        cell.layer.borderColor = tableView.backgroundColor?.cgColor
        cell.jobCategory.text = job.information.category
        cell.jobTitle.text = job.information.title
        cell.jobPic.image = job.getPictures()[0]
        cell.jobDistance.text = String(job.information.distance) + " km"
        cell.jobPostedTime.text = job.information.postedTime.timeAgoSinceDate(currentDate: Date(), numericDates: true)
        
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
            
        case "ShowMyPostDetails":
            guard let jobViewController = segue.destination as? JobDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMyPostsCell = sender as? MyPostsTableViewCell else {
                fatalError("Unexpected job sender: \(sender ?? "No sender")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMyPostsCell) else {
                fatalError("The selected meal cell is not being displayed by the table")
            }
            
            let selectedJob: Job
            // fetches the appropriate post
            if isFiltering() {
                selectedJob = filteredJobs[indexPath.row]
            } else {
                selectedJob = filteredJobs[indexPath.row]
            }
            
            jobViewController.job = selectedJob
            
        case "test":
            os_log("Showing user post", log: OSLog.default, type: .debug)
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "No identifier")")
        }
    }
    
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredJobs = filteredJobs.filter { job in
                return job.information.category.lowercased().contains(searchText.lowercased())
            }
            
        }
        tableView.reloadData()
    }
    
    //MARK: - Search-related methods
    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func loadMyPosts() -> [Job]{
        var jobs = HomeTableViewController.jobs
        let user = UserProfile.loadProfile()
        for (index, job) in jobs.enumerated() {
            
            if job.information.email == user?.email {
                print("I wrote this email!")
            }else{
                print("I did not write this email!")
                jobs = jobs.filter({$0 !== job})
            }
        }
        return jobs

    }
}
