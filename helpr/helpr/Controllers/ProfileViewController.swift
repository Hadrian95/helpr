//
//  ProfileViewController.swift
//  helpr
//
//  Created by walter.alvarez on 2018-11-14.
//  Copyright © 2018 helpr. All rights reserved.
//

import UIKit
import os.log
import Firebase
class ProfileViewController: UIViewController {

    @IBOutlet weak var ivProfilePic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblJobCount: UILabel!
    @IBOutlet weak var btnSkills: UIButton!
    @IBOutlet weak var profileInfoView: UIView!
    @IBOutlet weak var profileAddInfoView: UIView!
    @IBOutlet weak var profilelessContentView: UIView!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var bSettings: UIBarButtonItem!

    private var storage: StorageHelper = StorageHelper()
    private var database: DatabaseHelper = DatabaseHelper()
    private var picRef: String = ""
    var userID: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let userRef = Auth.auth().currentUser?.uid
        // User is not signed in so load simplified view that has no profile info
        if Auth.auth().currentUser == nil {
            signUp.backgroundColor = UIColor(named: "RoyalPurple")
            signUp.layer.borderWidth = 2
            signUp.layer.cornerRadius = 5
            signUp.layer.borderColor = UIColor(named: "RoyalPurple")?.cgColor
            //hide default view
            profileInfoView.isHidden = true
            profileAddInfoView.isHidden = true
            bSettings.isEnabled = false

            //show sign in option
            profilelessContentView.isHidden = false
        }
        // User is logged in, load their user info and picture
        else{
            if (userID == "") {
                lblName.text = UserProfile.name
                btnSkills.setTitle(String(UserProfile.skills.count) + " Skills", for: .normal)

                // get profile pic from database, use default picture if an error occurs
                database.getUser() { (user) in
                    let storageRef = Storage.storage().reference()
                    let ref = storageRef.child("profilePictures").child(userRef!).child(user!.picRef)
                    let phImage = UIImage(named: "defaultPhoto.png")
                    self.ivProfilePic.sd_setImage(with: ref, placeholderImage: phImage)
                }
            } else {
                self.navigationItem.rightBarButtonItem = nil // get rid of settings when viewing other user's profile
                ivProfilePic.isUserInteractionEnabled = false // cannot change picture when viewing other user's profile

                lblName.text = UserProfile.name
                btnSkills.setTitle(String(UserProfile.skills.count) + " Skills", for: .normal)

                // get profile pic from database, use default picture if an error occurs
                database.getUser(uID: userID) { (user) in
                    self.lblName.text = user?.name.components(separatedBy: " ")[0]
                    let skills = user!.skills
                    self.btnSkills.setTitle(String(skills.count) + " Skills", for: .normal)
                    let storageRef = Storage.storage().reference()
                    let ref = storageRef.child("profilePictures").child(self.userID).child(user!.picRef)
                    let phImage = UIImage(named: "defaultPhoto.png")
                    self.ivProfilePic.sd_setImage(with: ref, placeholderImage: phImage)
                }
            }
            //TODO: fix the damn square border radius that loads in the first time you nav to this page
            ivProfilePic.layer.cornerRadius = ivProfilePic.frame.width / 2
            ivProfilePic.layer.borderWidth = 3
            ivProfilePic.layer.borderColor = UIColor.init(named: "RoyalPurple")?.cgColor
        }
    }
    //redirect user to sign up screen
    @IBAction func signInAction(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let signUpNavController = storyBoard.instantiateViewController(withIdentifier: "SignUpNavController") as! UINavigationController
        self.present(signUpNavController, animated:true, completion:nil)
    }

    //MARK: Action
    @IBAction func imageClicked(_ sender: Any) {
        //Part of the ViewController Extensions
        presentPictureOptions()
    }

    //TODO: update the user's profile pic on Firebase
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        //Post Photo
        storage.updateProfile(picture: selectedImage) { path in
            print(path)
        }
        self.ivProfilePic.image = selectedImage

        // Dismiss the picker.
        picker.dismiss(animated: true, completion: nil)
    }

    func loadProfilePicture(){
        storage.loadProfilePicture(picRef: picRef){ image in
            self.ivProfilePic.image = image
        }
    }
}
