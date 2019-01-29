//
//  SignUpViewController.swift
//  helpr
//
//  Created by walter.alvarez on 2018-10-30.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit
import Firebase
class SignUpViewController: UIViewController {
    
    @IBOutlet weak var lFullName: UITextField!
    @IBOutlet weak var lEmail: UITextField!
    @IBOutlet weak var lPassword: UITextField!
    @IBOutlet weak var lConfirmPass: UITextField!
    @IBOutlet weak var bCreateAccount: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var database = DatabaseHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let width   = self.view.frame.width
        let height  = self.view.frame.height
        scrollView.contentSize = CGSize(width: width, height: height)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        bCreateAccount.backgroundColor = UIColor(named: "RoyalPurple")
        bCreateAccount.layer.borderColor = UIColor(named: "RoyalPurple")?.cgColor
        bCreateAccount.layer.cornerRadius = 5
        bCreateAccount.layer.borderWidth = 2
        
        lFullName.setBottomBorder()
        lEmail.setBottomBorder()
        lPassword.setBottomBorder()
        lConfirmPass.setBottomBorder()
        
        
    }
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToSignIn(_ sender: Any) {
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpDidTouch(_ sender: Any) {
        // 1
        let email = lEmail.text!
        let password = lPassword.text!
        
        
        
        //Authenticate and add user
        database.createUser(email: email, password: password){(error) -> () in
            if error != nil {
                print(error!._code)
                self.handleError(error!)
                return
            }else{
                print("No error occured in account creation")
                self.validSignupHandle()
            }
        }
       
    
//        //Pop-ups to show what's going on.
//        //TODO: Pop-ups should be replaced with pretty designed screens.
//        if error == nil {
//            validSignupHandle()
//        }else{
//            invalidSignupHandle(error: error!)
//        }
    }
    
    private func validSignupHandle(){
        database.addUserInformation(name: lFullName.text!, photoURL: nil){(error) -> () in
            if error != nil {
                print(error!._code)
                self.handleError(error!)
            }else {
                let alert = UIAlertController(title: "Sign-up Successful", message: "You have successfully signed up for helpr!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ action in self.performSegue(withIdentifier: "goSignIn", sender: self) }))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    
    }
    
    private func invalidSignupHandle(error: Error) {
        let errCode = AuthErrorCode(rawValue: error._code)!
        var message = ""
        switch errCode {
        case .invalidEmail:
            message = "Email not valid. Please try again with a valid email address."
        case .emailAlreadyInUse:
            message = "You have already signed-up for helpr!"
        default:
            message = error.localizedDescription
        }
        let alert = UIAlertController(title: "Sign-up Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
        
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
