//
//  ChangePasswordViewController.swift
//  helpr
//
//  Created by adrian.parcioaga and walter.alvarez on 2018-11-19.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var tfCurPass: UITextField!
    @IBOutlet weak var tfNewPass: UITextField!
    @IBOutlet weak var tfConfNewPass: UITextField!
    @IBOutlet weak var btnUpdatePass: UIButton!
    @IBOutlet weak var btnResetPass: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //To enforce the user's password consists of at least one capital, and number, length of 8
        //tfNewPass.passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: lower; required: digit; minlength: 8;")
        
        tfNewPass.passwordRules = UITextInputPasswordRules(descriptor: "allowed: unicode; minlength: 8;")
        tfConfNewPass.passwordRules = UITextInputPasswordRules(descriptor: "allowed: unicode; minlength: 8;")
    }
    
    //MARK: Actions
    
    @IBAction func nextField(_ sender: UITextField) {
        if sender.accessibilityIdentifier == "curPass" {
           print("Hit return on current password field")
            tfCurPass.resignFirstResponder()
            tfNewPass.becomeFirstResponder()
        }
        else if (sender.accessibilityIdentifier == "newPass") {
            print("Hit return on new password field")
            tfNewPass.resignFirstResponder()
            tfConfNewPass.becomeFirstResponder()
        }
    }
    
    @IBAction func updatePass(_ sender: UIButton) {
        if tfNewPass.text != tfConfNewPass.text {
            //generate alert stating the passwords must match
        }
        else if tfCurPass.text == tfNewPass.text || tfCurPass.text == tfConfNewPass.text{
            //generate alert stating new pass is same as old pass
            //should we allow old passwords to be used?
        }
        else {
            //update user's account password
            //notify user password has been successfully updated
        }
    }
    
    @IBAction func resetPass(_ sender: UIButton) {
        //send email to current user's email. What will this trigger?
        //one time code to login? temporary password?
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
