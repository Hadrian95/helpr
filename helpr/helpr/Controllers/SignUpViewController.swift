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
    var userProfilePic = UIImage()
    
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
            self.dismiss(animated: true, completion: nil)
            self.present(vc, animated: true, completion: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let jobViewController = segue.destination as? AddSkillsViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        jobViewController.signUpParent = self
    }
}

class AddSkillsViewController: UIViewController {
    var signUpParent: SignUpViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let jobViewController = segue.destination as? AddPhotoViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        jobViewController.signUpParent = signUpParent!
    }
}

class AddPhotoViewController: UIViewController {
    var signUpParent: SignUpViewController?
    @IBOutlet weak var userProfilePic: UIImageView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let jobViewController = segue.destination as? FinishSignUpViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        jobViewController.signUpParent = signUpParent!
    }
    
    @IBAction func addPic(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //after photo library opened, if cancel is hit simply close the photo library in animated fashion
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    //if user selects photo update collectionViewCell image with selected image. Logic implemented to determine if photo is stock and thus needs to be replaced or if there is an 'add photo' canvas that can be updated
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        userProfilePic.image = selectedImage
        signUpParent?.userProfilePic = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}

class FinishSignUpViewController : UIViewController {
    
    var database = DatabaseHelper()
    var storage = StorageHelper()
    var signUpParent = SignUpViewController()
    var dataToSave: [String: Any] = [:]
    var profilePic: [UIImage] = []
    
    @IBAction func registerUser(_ sender: Any) {
        let email = signUpParent.lEmail.text!
        let password = signUpParent.lPassword.text!
        let name = signUpParent.lFullName.text!
        profilePic.append(signUpParent.userProfilePic)
        
        dataToSave = ["name": name, "email": email, "skills": ["App Development", "Swift"]]
        
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
    
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! MyTabBarViewController
            self.dismiss(animated: true, completion: nil)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func validSignupHandle(){
        database.addUserInformation(dataToSave: dataToSave, photoURL: nil){(error) -> () in
            if error != nil {
                print(error!._code)
                self.handleError(error!)
            }else {
                let uID = Auth.auth().currentUser?.uid
                self.storage.uploadImages(root: "profilePictures", ID: uID!, imagesArray: self.profilePic) { (uploadedImageUrlsArray) in
                    let pictures = uploadedImageUrlsArray
                }
                let alert = UIAlertController(title: "Sign-up Successful", message: "You have successfully signed up for helpr!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ action in self.performSegue(withIdentifier: "contSignup", sender: self) }))
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

}
