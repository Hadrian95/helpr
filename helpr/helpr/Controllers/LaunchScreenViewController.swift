//
//  LaunchScreenViewController.swift
//  helpr
//
//  Created by Hilmi Abou-Saleh on 2018-12-04.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit
import Firebase
class LaunchScreenViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadJobs()
        // Do any additional setup after loading the view.
    }
    
    private func loadJobs(){
        let database = DatabaseHelper()
        
        database.getJobs(){ jobs in
            //ExploreTableViewController.jobs = jobs
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            if (Auth.auth().currentUser?.uid != nil) {
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarViewController") as! EBRoundedTabBarController
                self.present(nextViewController, animated:true, completion:nil)
            }
            else {
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "StartScreen") as! WelcomeViewController
                self.present(nextViewController, animated:true, completion:nil)
            }
            
        }
    }
}
