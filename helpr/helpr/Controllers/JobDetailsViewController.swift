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
import SCLAlertView
import MapKit

class JobDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MKMapViewDelegate {
    
    var job : Job?
    var bidAmount : Double = 0
    var bidInput : String = ""

    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobDescription: UITextView!
    @IBOutlet weak var jobPic: UIImageView!
    @IBOutlet weak var bidButton: UIButton!
    @IBOutlet weak var jobCategory: UILabel!
    @IBOutlet weak var jobPostedTime: UILabel!
    @IBOutlet weak var jobPhotos: UICollectionView!
    @IBOutlet weak var jobPicsControl: UIPageControl!
    @IBOutlet weak var mapView: MKMapView!
    
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
        
        //center mapView on Job location
        mapView.delegate = self
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let lat = job?.information.anonLocation.latitude
        let long = job?.information.anonLocation.longitude
        let center = CLLocation(latitude: lat ?? 0, longitude: long ?? 0)
        let recenterRegion = MKCoordinateRegion(center: center.coordinate, span: span)
        mapView.setRegion(recenterRegion, animated: true)
        addRadiusCircle(location: center)
        
    }

    @IBAction func bidBtnAction(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        if (Auth.auth().currentUser?.uid != nil) {
            let navController = storyBoard.instantiateViewController(withIdentifier: "BidNavController") as! UINavigationController
            let bidViewController = navController.viewControllers.first as! BidViewController
            bidViewController.chatID = nil
            bidViewController.job = job!
            self.present(navController, animated:true, completion:nil)

        }
        else {
            let alertView = SCLAlertView()
            alertView.addButton("Sign Up") {
                let signUpNavController = storyBoard.instantiateViewController(withIdentifier: "SignUpNavController") as! UINavigationController
                self.present(signUpNavController, animated:true, completion:nil)
                //self.dismiss(animated: true, completion: nil)
                
            }
            alertView.showWarning("Warning", subTitle: "In order to place a bid on a job you must be logged into the application.")
        }
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
        let phImage = UIImage(named: "jobDefault.png")
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
    
    // MARK: - MapView methods
    func addRadiusCircle(location: CLLocation){
        let circle = MKCircle(center: location.coordinate, radius: 500 as CLLocationDistance)
        mapView.addOverlay(circle)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.purple
            circle.fillColor = UIColor(named: "RoyalPurple")
            circle.alpha = 0.5
            circle.lineWidth = 1
            return circle
        }
        else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
