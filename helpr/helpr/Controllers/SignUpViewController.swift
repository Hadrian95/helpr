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

class AddSkillsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var signUpParent: SignUpViewController?
    
    @IBOutlet weak var tblSkillstoAdd: UITableView!
    @IBOutlet weak var tblSkillsMaster: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var skills = ["Aesthetician","Animal Grooming", "Barber (Men)", "Basic Auto Repair", "Household Cleaning", "Java", "Plumbing", "Swift"]
    var filteredSkills = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    var isSearching = false
    
    override func viewDidLoad() {
        searchBar.delegate = self
        
        tblSkillsMaster.accessibilityIdentifier = "tblSkillsMaster"
        tblSkillstoAdd.accessibilityIdentifier = "tblSkillstoAdd"
        
        tblSkillsMaster.delegate = self
        tblSkillsMaster.dataSource = self
        tblSkillstoAdd.delegate = self
        tblSkillstoAdd.dataSource = self
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text Did Change Called")
        if searchBarIsEmpty() {
            isSearching = false
            view.endEditing(true)
            tblSkillsMaster.isHidden = true
            tblSkillstoAdd.isHidden = false
            tblSkillstoAdd.reloadData()
            print("Search bar empty")
        }
        else {
            isSearching = true
            tblSkillsMaster.isHidden = false
            tblSkillstoAdd.isHidden = true
            filteredSkills = skills.filter({$0.contains(searchText)})
        tblSkillsMaster.reloadData()
            print("Search bar has content: \(searchText)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let jobViewController = segue.destination as? AddPhotoViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        jobViewController.signUpParent = signUpParent!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredSkills.count
        }
        else {
            return skills.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell
            if tableView.accessibilityIdentifier == "tblSkillsMaster" {
            cell = tableView.dequeueReusableCell(withIdentifier: "skillMasterCell", for: indexPath)
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "skillAddCell", for: indexPath)
        }
        
        if isSearching {
            cell.textLabel?.text = filteredSkills[indexPath.item]
        }
        else {
            cell.textLabel?.text = skills[indexPath.item]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            skills.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension AddSkillsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
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
    var profilePic: UIImage? = nil
    var picRef: String = ""
    
    @IBAction func registerUser(_ sender: Any) {
        let email = signUpParent.lEmail.text!
        let password = signUpParent.lPassword.text!
        let name = signUpParent.lFullName.text!
        profilePic = signUpParent.userProfilePic
        picRef = NSUUID().uuidString + ".png"
        
        dataToSave = ["name": name, "email": email, "skills": ["App Development", "Swift"], "profilePic": picRef]
        
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
                self.storage.uploadPicture(root: "profilePictures", ID: uID!, image: self.profilePic!, picRef: self.picRef)
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
