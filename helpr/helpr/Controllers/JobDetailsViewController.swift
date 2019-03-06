//
//  JobDetailsViewController.swift
//  helpr
//
//  Created by adrian.parcioaga on 2018-10-30.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase
import FirebaseUI

class JobDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var job : Job?
    var bidAmmount : Double = 0
    var bidInput : String = ""

    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobDescription: UITextView!
    @IBOutlet weak var jobPic: UIImageView!
    @IBOutlet weak var bidButton: UIButton!
    @IBOutlet weak var jobCategory: UILabel!
    @IBOutlet weak var jobPostedTime: UILabel!
    @IBOutlet weak var jobPhotos: UICollectionView!
    @IBOutlet weak var jobPicsControl: UIPageControl!
    
    var arrJobPhotos = [String]() //allow update of UICollectionViewCells
    var indexPathForCell : IndexPath = [] //variable to allow updating of photos
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        jobPhotos.delegate = self
        jobPhotos.dataSource = self
        
        bidButton.layer.cornerRadius = 5
        
        jobDescription.layer.cornerRadius = 8
        if let job = job {
            navigationItem.title = "Job #" + String(job.information.id)
            jobTitle.text = job.information.title
            jobDescription.text = job.information.postDescription
            //jobPic.image = job.pictureData[0]
            //arrJobPhotos = job.pictureData
            arrJobPhotos = job.information.pictures as! [String]
            jobCategory.text = job.information.category
            jobPostedTime.text = job.information.postedTime.timeAgoSinceDate(currentDate: Date(), numericDates: true)
        }
        jobPicsControl.numberOfPages = arrJobPhotos.count
        self.jobPhotos.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func bidOnClick(_ sender: Any) {
        let alert = UIAlertController(title: "Want to bid on this Job?\n Enter bid in dollars below", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter your bid ammount here"
            textField.keyboardType = UIKeyboardType.decimalPad
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let bid = alert.textFields?.first?.text {
                self.bidInput = bid
            }
            if let bidAmmount = Float(self.bidInput) {
                let success = UIAlertController(title: "Bid of $" + String(bidAmmount) + " placed\n\n Please wait for the poster to respond", message: nil, preferredStyle: .alert)
                success.addAction(UIAlertAction(title: "View Bid", style: .default))
                success.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(success, animated: true)
            } else {
                // This statement is printed.
                let fail = UIAlertController(title: "Please Enter a Valid Bid", message: nil, preferredStyle: .alert)
                fail.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(fail, animated: true)
            }
            
        }))
        self.present(alert, animated: true)
        
        // Try to convert to an Int.
        
    }
    
    //MARK: - CollectionView methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrJobPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        
        // get job image from database, use default picture if an error occurs
        let storageRef = Storage.storage().reference()
        let ref = storageRef.child(arrJobPhotos[indexPath.row])
        let phImage = UIImage(named: "defaultPhoto.png")
        cell.jobPhoto.sd_setImage(with: ref, placeholderImage: phImage)
        //cell.jobPhoto.image = arrJobPhotos[indexPath.row]
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //round to nearest page, though with paging enabled this should never have a rounding problem
        let width = scrollView.frame.size.width;
        jobPicsControl.currentPage = Int((scrollView.contentOffset.x + (0.5 * width)) / width)
    }
 
    //update photo displayed when pageControl dot is tapped
    @IBAction func changePhoto(_ sender: UIPageControl) {
        
        self.jobPhotos.contentOffset.x = CGFloat(Int(self.jobPhotos.frame.width) * jobPicsControl.currentPage)
    }
    
    // MARK: - Private Methods

    /*
    // MARK: - Navigation

     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
