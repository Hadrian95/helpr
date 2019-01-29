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

    private func loadJobs(){
        let database = DatabaseHelper()
        
        database.readJobs(){ jobs in
            HomeTableViewController.jobs = jobs
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "StartScreen") as! LetUsKnowViewController
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    
}
