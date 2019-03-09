//
//  ProfileViewController.swift
//  helpr
//
//  Created by walter.alvarez on 2018-11-14.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userRef = Auth.auth().currentUser?.uid
        if Auth.auth().currentUser == nil {
            // User is not signed in.
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
            
            /*
            if let storyboard = self.storyboard {
                let vc = storyboard.instantiateViewController(withIdentifier: "StartScreen") as! WelcomeViewController
                self.present(vc, animated: true, completion: nil)
            }
             */
            
        }else{
            lblName.text = UserProfile.name
            //lblSkillCount.text = String(UserProfile.skills.count)
            btnSkills.setTitle(String(UserProfile.skills.count) + " Skills", for: .normal)
            
            // get profile pic from database, use default picture if an error occurs
            database.getUser() { (user) in
                let storageRef = Storage.storage().reference()
                let ref = storageRef.child("profilePictures").child(userRef!).child(user!.picRef)
                let phImage = UIImage(named: "userProfileDefault.png")
                self.ivProfilePic.sd_setImage(with: ref, placeholderImage: phImage)
            }
            
            ivProfilePic.layer.cornerRadius = ivProfilePic.frame.width / 2
            ivProfilePic.layer.borderWidth = 3
            ivProfilePic.layer.borderColor = UIColor.init(named: "RoyalPurple")?.cgColor
        }
    }
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
    
    //This is magic. Where does this get called?
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
