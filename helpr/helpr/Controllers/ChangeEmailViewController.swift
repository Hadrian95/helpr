//
//  ChangeEmailViewController.swift
//  helpr
//
//  Created by adrian.parcioaga and walter.alvarez on 2018-11-19.
//  Copyright © 2018 helpr. All rights reserved.
//
//  Incomplete: need to load user's actual info and implement styling/ finish form data

import UIKit

class ChangeEmailViewController: UIViewController {

    @IBOutlet weak var tfNewEmail: UITextField!
    @IBOutlet weak var tfConfEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    //MARK: Actions
    
    /*incomplete method
     @IBAction func checkValidEmail(_ sender: UITextField) {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let emailValid = emailTest.evaluate(with: sender.text)
        if !emailValid {
            print("\(emailValid): Incorrect email format detected")
            //alert stating email entered is invalid
        }
     }
    */
    @IBAction func nextField(_ sender: UITextField) {
        if sender.accessibilityIdentifier == "newEmail" {
            print("Hit return on desired email field")
            tfNewEmail.resignFirstResponder()
            tfConfEmail.becomeFirstResponder()
        }
    }
}
