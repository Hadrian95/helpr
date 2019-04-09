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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let database = DatabaseHelper()

        bStart.layer.cornerRadius = 5
        bStart.layer.borderWidth = 2
        bStart.layer.borderColor = UIColor.white.cgColor
        
    }
}
























