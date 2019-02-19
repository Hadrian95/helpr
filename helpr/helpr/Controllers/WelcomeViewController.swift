//
//  LetUsKnowViewController.swift
//  helpr
//
//  Created by walter.alvarez on 2018-10-30.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit
import Firebase
class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var bStart: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var bSignIn: UIButton!
    
    var storage = StorageHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let database = DatabaseHelper()
        
        // Do any additional setup after loading the view, typically from a nib.
        let handle = Auth.auth().addStateDidChangeListener { (auth,user) in
            if (user != nil) {
                database.getUser() { (user) -> () in
                    UserProfile.name = user!.name
                    UserProfile.email = user!.email
                    UserProfile.skills = user!.skills
                    self.storage.loadProfilePicture(picRef: user!.picRef){ image in
                        UserProfile.profilePic = image
                    }
                    self.welcomeLabel.text = "Welcome back, " + user!.name.components(separatedBy: " ")[0] + "!"
                    self.bSignIn.setTitle("Switch account?" , for: .normal)
                }
            }
            else {
                print ("No user signed in.")
            }
        }
        
        bStart.layer.cornerRadius = 5
        bStart.layer.borderWidth = 2
        bStart.layer.borderColor = UIColor(named: "RoyalPurple")?.cgColor
    }
}
























