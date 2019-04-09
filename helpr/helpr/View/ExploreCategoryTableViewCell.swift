//
//  ExploreCategoryTableViewCell.swift
//  helpr
//
//  Created by Critical on 2019-03-12.
//  Copyright © 2019 ryan.konynenbelt. All rights reserved.
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // reload on new post added
    @objc func loadJobs(notification: NSNotification){
        jobCollectionView.reloadData()
    }
}
