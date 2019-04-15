//
//  ExploreCategoryTableViewCell.swift
//  helpr
//
//  Created by adrian.parcioaga on 2019-03-12.
//  Copyright © 2019 helpr. All rights reserved.
//

import UIKit
import Firebase

class ExploreCategoryTableViewCell: UITableViewCell {
    //var categoryJobs = [Job]()
    @IBOutlet weak var jobCollectionView: UICollectionView!
    
    public func setScrollPosition(x: CGFloat) {
       print(jobCollectionView)
        jobCollectionView.setContentOffset(CGPoint(x: x >= 0 ? x : 0, y: 0), animated: false)
    }
    
    public func getScrollPosition() -> CGFloat {
        return jobCollectionView.contentOffset.x
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        jobCollectionView.delegate = dataSourceDelegate
        jobCollectionView.dataSource = dataSourceDelegate
        jobCollectionView.tag = row
        jobCollectionView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        NotificationCenter.default.addObserver(self, selector: #selector(loadJobs(notification:)), name: NSNotification.Name(rawValue: "reloadCell"), object: nil)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // reload on new post added
    @objc func loadJobs(notification: NSNotification){
        jobCollectionView.reloadData()
    }
}

//extension ExploreCategoryTableViewCell : UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1
//        //return categoryJobs.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cellIdentifier = "exploreJobCell"
//
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ExploreJobCollectionViewCell else {
//            fatalError("The dequeued cell is not an instance of exploreJobCell")
//        }
//
//        // fetches the appropriate job for the data source layout
//        let job : Job
//        //        if isFiltering() {
//        //            job = filteredJobs[indexPath.row]
//        //        } else {
//        job = self.categoryJobs[indexPath.row]
//        //        }
//
//        cell.layer.cornerRadius = 5.0
//        cell.layer.masksToBounds = true
//        cell.layer.borderWidth = 1.0
//        cell.layer.borderColor = collectionView.backgroundColor?.cgColor
//        cell.jobTitle.text = job.information.title
//
//        // get job image from database, use default picture if an error occurs
//        let storageRef = Storage.storage().reference()
//        let ref = storageRef.child((job.information.pictures[0])!)
//        let phImage = UIImage(named: "jobDefault.png")
//        cell.jobPic.sd_setImage(with: ref, placeholderImage: phImage)
//
//        cell.jobDistance.text = String(job.information.distance) + " km"
//        cell.jobPostedTime.text = job.information.postedTime.timeAgoSinceDate(currentDate: Date(), numericDates: true)
//        return cell
//    }
//
//}

//extension ExploreCategoryTableViewCell : UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemsPerRow:CGFloat = 1.5
//        let hardCodedPadding:CGFloat = 5
//        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
//        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
//        return CGSize(width: itemWidth, height: itemHeight)
//    }
//
//}
