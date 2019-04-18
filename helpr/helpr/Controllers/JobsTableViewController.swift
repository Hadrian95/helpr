//
//  JobsTableViewController.swift
//  helpr
//
//  Created by adrian.parcioaga on 2018-10-30.
//  Updated by walter.alvarez on 2018-12-06.
//  Copyright © 2018 helpr. All rights reserved.
//

import UIKit
import os.log
import Firebase
import FirebaseUI

class JobsTableViewController: UITableViewController, UISearchResultsUpdating {

    //MARK: Properties
    @IBOutlet weak var jobsSegment: UISegmentedControl!
    @IBOutlet weak var JobsTableView: UITableView!
    
    //var jobs = HomeTableViewController.jobs
    var db = Firestore.firestore()
    var filteredJobs = [Job]()
    var isPurple = Bool()
    var acceptedJobs = [Job]()
    var postedJobs = [Job]()
    var database = DatabaseHelper()
    var userID = Auth.auth().currentUser?.uid
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView(notification:)), name: NSNotification.Name(rawValue: "reloadMyJobs"), object: nil)
        
        setNeedsStatusBarAppearanceUpdate()
        filteredJobs = SearchTableViewController.jobs
        if (userID != nil) {
            db.collection("users").document(userID!).collection("posts")
                .addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching user posts snapshots: \(String(describing: error))")
                        return
                    }
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            let postID = diff.document.documentID
                            DispatchQueue.main.async {
                                self.database.getJob(jobID: postID) { (post) in
                                    self.postedJobs.append(post)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadMyJobs"), object: nil)
                                }
                            }
                        }
                    }
            }
            db.collection("users").document(userID!).collection("acceptedJobs")
                .addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching user posts snapshots: \(String(describing: error))")
                        return
                    }
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            let postID = diff.document.documentID
                            DispatchQueue.main.async {
                                self.database.getJob(jobID: postID) { (post) in
                                    self.acceptedJobs.append(post)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadMyJobs"), object: nil)
                                }
                            }
                        }
                    }
            }
        }
        
        isPurple = false
        
        //scale segmentedControl
        jobsSegment.setWidth(UIScreen.main.bounds.width/2, forSegmentAt: 0)
        jobsSegment.setWidth(UIScreen.main.bounds.width/2, forSegmentAt: 1)
        jobsSegment.transform = CGAffineTransform(scaleX: 1.05, y: 1.25)
//        jobsSegment.setTitleTextAttributes([
//            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)
//            ], for: .normal)
//
//        jobsSegment.setTitleTextAttributes([
//            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)
//            ], for: .selected)
//
        definesPresentationContext = true
    }
    
    @objc func reloadView(notification: NSNotification) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .white
        v.addSubview(jobsSegment)
        return v
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredJobs.count
        }
        else if (jobsSegment.selectedSegmentIndex == 0) {
            return acceptedJobs.count
        }
        else {
            return postedJobs.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "JobsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? JobsTableViewCell else {
            fatalError("The dequeued cell is not an instance of JobsTableViewCell")
        }
        // fetches the appropriate job for the data source layout
        let job : Job
        if (jobsSegment.selectedSegmentIndex == 0) {
            if isFiltering() {
                job = filteredJobs[indexPath.row]
            } else {
                job = acceptedJobs[indexPath.row]
            }
        }
        else {
            if isFiltering() {
                job = filteredJobs[indexPath.row]
            } else {
                job = postedJobs[indexPath.row]
            }
        }
        
        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 3.0
        cell.layer.borderColor = tableView.backgroundColor?.cgColor
        cell.jobCategory.text = job.information.category
        cell.jobTitle.text = job.information.title
        
        // get job image from database, use default picture if an error occurs
        let storageRef = Storage.storage().reference()
        let ref = storageRef.child((job.information.pictures[0])!)
        let phImage = UIImage(named: "jobDefault.png")
        cell.jobPic.sd_setImage(with: ref, placeholderImage: phImage)
        
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
            
        case "showMyJobDetails":
            guard let jobViewController = segue.destination as? JobDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedHomeCell = sender as? JobsTableViewCell else {
                fatalError("Unexpected job sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedHomeCell) else {
                fatalError("The selected meal cell is not being displayed by the table")
            }
            
            let selectedJob: Job
            // fetches the appropriate meal
            if (jobsSegment.selectedSegmentIndex == 0) {
                if isFiltering() {
                    selectedJob = filteredJobs[indexPath.row]
                } else {
                    selectedJob = acceptedJobs[indexPath.row]
                }
            }
            else {
                if isFiltering() {
                    selectedJob = filteredJobs[indexPath.row]
                } else {
                    selectedJob = postedJobs[indexPath.row]
                }
            }
            
            jobViewController.job = selectedJob
            
        case "jobsCreatePost":
            guard let createPostViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredJobs = SearchTableViewController.jobs.filter { job in
                return job.information.category.lowercased().contains(searchText.lowercased())
            }
            
        } else {
            filteredJobs = SearchTableViewController.jobs
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
    @IBAction func switchJobsView(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        self.tableView.reloadData()
    }
}
