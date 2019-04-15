//
//  LaunchScreenViewController.swift
//  helpr
//
//  Created by walter alvarez and adrian parcioaga on 2018-12-04.
//  Copyright © 2018 helpr. All rights reserved.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //query DB for list of jobs and store locally some of user's info for reuse
    private func loadJobs(){
        let database = DatabaseHelper()
        
        database.getJobs(){ jobs in
            //ExploreTableViewController.jobs = jobs
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            if (Auth.auth().currentUser?.uid != nil) {
                _ = Auth.auth().addStateDidChangeListener { (auth,user) in
                    if (user != nil) {
                        database.getUser() { (user) -> () in
                            UserProfile.name = user!.name
                            UserProfile.email = user!.email
                            UserProfile.skills = user!.skills
                            UserProfile.profilePicRef = user!.picRef
                        }
                    }
                }
                //if user logged in, proceed to explore page
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarViewController") as! EBRoundedTabBarController
                self.present(nextViewController, animated:true, completion:nil)
            }
            //if no user logged in, redirect to title screen
            else {
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "StartScreen") as! WelcomeViewController
                self.present(nextViewController, animated:true, completion:nil)
            }
            
        }
    }
}
