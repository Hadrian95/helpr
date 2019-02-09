//
//  SignIn.swift
//  helpr
//
//  Created by walter.alvarez on 2018-10-30.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit
import Firebase
import os.log

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var bLogIn: UIButton!
    @IBOutlet weak var bSignUp: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let width   = self.view.frame.width
        let height  = self.view.frame.height
        scrollView.contentSize = CGSize(width: width, height: height - 40)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        bLogIn.layer.cornerRadius = 5
        bLogIn.layer.borderWidth = 2
        bLogIn.layer.borderColor = UIColor(named: "RoyalPurple")?.cgColor
        
        
        emailField.setBottomBorder()
        passwordField.setBottomBorder()
        
    }
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextField(_ sender: UITextField) {
        if sender.accessibilityIdentifier == "emailField" {
            print("Hit return on email field")
            passwordField.becomeFirstResponder()
        }
        else {
            print("Hit return on password field")
            passwordField.resignFirstResponder()
        }
    }
    
    @IBAction func touchUpOutside(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func signInDidPress(_ sender: Any) {
        let email = emailField.text!
        let password = passwordField.text!
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            
            if error == nil {
                guard (authResult?.user) != nil else { return }

                self.saveUser()
                let alert = UIAlertController(title: "Sign-in successful", message: "You have successfully signed in!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ action in self.performSegue(withIdentifier: "successfulSignIn", sender: self) }))
                self.present(alert, animated: true, completion: nil)
                //successfulSignIn
                

            }else{
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    var message = ""
                    switch errCode {
                    case .invalidEmail:
                        message = "Email not valid. Please try again with a valid email address."
                    case .emailAlreadyInUse:
                        message = "You have already signed-up for helpr!"
                    case .wrongPassword:
                        message = "Password incorrect. Please try again."

                    default:
                        message = error?.localizedDescription ?? "An error occurred. Please try again."
                    }
                    let alert = UIAlertController(title: "Sign-in failed", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }            }
        }

    }
    
    private func saveUser(){
        let user:User = Auth.auth().currentUser!
        let userProfile = UserProfile(name: user.displayName ?? "invalid display name" , email: user.email ?? "invalid email address")
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(userProfile, toFile: UserProfile.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("User profile successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save user profile...", log: OSLog.default, type: .error)
        }
    }
    //MARK: Methods to manage keybaord
    @objc func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame: CGRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView.contentInset.bottom = keyboardFrame.height
    }
    
    
    
}
