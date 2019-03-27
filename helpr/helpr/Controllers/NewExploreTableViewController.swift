//
//  NewExploreTableViewController.swift
//  helpr
//
//  Created by Critical on 2019-03-12.
//  Copyright © 2019 ryan.konynenbelt. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase
import FirebaseUI

class NewExploreTableViewController: UITableViewController {
    
    //MARK: Properties
    var database = DatabaseHelper()
    var db = Firestore.firestore()
    var docRef : DocumentReference!
    var jobs = [Job]()
    var categories : [[String : Bool]] = [["Featured" : true], ["Recommended For You" : true], ["Nearest To You" : true], ["Automotive" : true], ["Cleaning" : true], ["Design" : true], ["Development" : true], ["Furniture Assembly" : true], ["Minor Repair" : true], ["Technology" : true], ["Tech Repair" : true], ["Tutoring" : true], ["Web Design" : true]]
    var catKeys = ["Featured", "Recommended For You", "Nearest To You", "Automotive", "Cleaning", "Design", "Development", "Furniture Assembly", "Minor Repair", "Technology", "Tech Repair", "Tutoring", "Web Design"]
    var storedOffsets = [IndexPath : CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: NSNotification.Name(rawValue: "reloadNewExplore"), object: nil)

        db.collection("jobs").order(by: "postedTime", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(String(describing: error))")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        let jobID = diff.document.documentID
                        DispatchQueue.main.async {
                            self.database.getJob(jobID: jobID) { job in
                                self.jobs.append(job)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadNewExplore"), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadMyJobs"), object: nil)
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
    
    // reload on new post added
    @objc func loadList(notification: NSNotification){
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return catKeys[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exploreTableCell") as! ExploreCategoryTableViewCell
        cell.setScrollPosition(x: storedOffsets[indexPath] ?? 0)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? ExploreCategoryTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? ExploreCategoryTableViewCell else { return }
        
        storedOffsets[indexPath] = tableViewCell.getScrollPosition()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = .white
            if (section == 0) {
                headerView.textLabel?.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.regular)
            } else if (section < 3) {
                headerView.textLabel?.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.regular)
            } else  {
                headerView.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 50.0
        } else {
            return 35.0
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension NewExploreTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jobs.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "exploreJobCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ExploreJobCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of exploreJobCell")
        }
        
        // fetches the appropriate job for the data source layout
        let job : Job
        //        if isFiltering() {
        //            job = filteredJobs[indexPath.row]
        //        } else {
        job = self.jobs[indexPath.row]
        //        }
        
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = collectionView.backgroundColor?.cgColor
        cell.jobTitle.text = job.information.title
        cell.jobCategory.text = job.information.category
        
        // get job image from database, use default picture if an error occurs
        let storageRef = Storage.storage().reference()
        let ref = storageRef.child((job.information.pictures[0])!)
        let phImage = UIImage(named: "jobDefault.png")
        cell.jobPic.sd_setImage(with: ref, placeholderImage: phImage)
        
        cell.jobDistance.text = String(job.information.distance) + " km"
        cell.jobPostedTime.text = job.information.postedTime.timeAgoSinceDate(currentDate: Date(), numericDates: true)
        
        cell.job = job
        
        cell.jobCategory.isHidden = true
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
            
        case "showJobDetails":
            guard let jobViewController = segue.destination as? JobDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedJobCell = sender as? ExploreJobCollectionViewCell else {
                fatalError("Unexpected job sender: \(sender)")
            }

            jobViewController.job = selectedJobCell.job
            
        case "createPost":
            guard let createPostViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
        case "showSearchJobs":
            guard let searchViewController = segue.destination as? ExploreTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
}
