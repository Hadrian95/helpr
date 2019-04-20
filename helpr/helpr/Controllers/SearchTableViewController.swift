//
//  HomeTableViewController.swift
//  helpr
//
//  Created by Adrian.Parcioaga on 2018-10-30.
//  Copyright © 2018 helpr. All rights reserved.
//

//this page will largely need reworking to be useful, can ignore most of what it does for now

import UIKit
import os.log
import Firebase
import CodableFirebase
import FirebaseUI
class SearchTableViewController: UITableViewController, UISearchBarDelegate {

    //MARK: Properties
    var database = DatabaseHelper()
    var db = Firestore.firestore()
    var docRef : DocumentReference!
    static var jobs = [Job]()
    var filteredJobs = [Job]()
    var isPurple = Bool()
    let cellSpacingHeight: CGFloat = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: NSNotification.Name(rawValue: "reloadExplore"), object: nil)

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
                                SearchTableViewController.jobs.append(job)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadExplore"), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadMyJobs"), object: nil)
                            }
                        }
                    }
                }
        }

//        filteredJobs = ExploreTableViewController.jobs
        isPurple = false
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
//        searchBar.delegate = self

        definesPresentationContext = true
    }

    // reload on new post added
    @objc func loadList(notification: NSNotification){
        self.tableView.reloadData()
    }

    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            filteredJobs = SearchTableViewController.jobs.filter { job in
                return job.information.category.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredJobs = SearchTableViewController.jobs
        }
        tableView.reloadData()
    }


    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isFiltering() {
//            return filteredJobs.count
//        }
        return SearchTableViewController.jobs.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "HomeTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HomeTableViewCell else {
            fatalError("The dequeued cell is not an instance of HomeTableVieCell")
            }

        // fetches the appropriate job for the data source layout
        let job : Job
//        if isFiltering() {
//            job = filteredJobs[indexPath.row]
//        } else {
            job = SearchTableViewController.jobs[indexPath.row]
//        }

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


    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch (segue.identifier ?? "") {

        case "ShowJobDetails":
            guard let jobViewController = segue.destination as? JobDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedHomeCell = sender as? HomeTableViewCell else {
                fatalError("Unexpected job sender: \(sender)")
            }

            guard let indexPath = tableView.indexPath(for: selectedHomeCell) else {
                fatalError("The selected job cell is not being displayed by the table")
            }

            let selectedJob: Job
            // fetches the appropriate job
//            if isFiltering() {
//                selectedJob = filteredJobs[indexPath.row]
//            } else {
                selectedJob = SearchTableViewController.jobs[indexPath.row]
//            }

            jobViewController.job = selectedJob

        case "CreatePost":
            guard let createPostViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }

    //MARK: Search-related methods

//    private func searchBarIsEmpty() -> Bool {
//        // Returns true if the text is empty or nil
//        return searchBar.text?.isEmpty ?? true
//    }
//
//    private func isFiltering() -> Bool {
//        return !searchBarIsEmpty()
//    }
}
