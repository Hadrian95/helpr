//
//  UpdateNameViewController.swift
//  helpr
//
//  Created by adrian.parcioaga and walter.alvarez on 2018-11-19.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit

class UpdateNameViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tfCurName: UITextField!
    @IBOutlet weak var tfNewName: UITextField!
    @IBOutlet weak var tvReasoning: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tvReasoning.layer.borderColor = UIColor.lightGray.cgColor
        tvReasoning.layer.borderWidth = 1
        tvReasoning.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Methods
    
    //clear 'placeholder' text
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Reasoning field selected for editing")
        if (tvReasoning.text == "Briefly explain why you are requesting a name change (such as marriage, divorce, or legally updated, etc..)") {
            tvReasoning.text = ""
        }
        tvReasoning.textColor = UIColor.black
    }
    
    //limit character count in Description field
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 250   // 250 Limit Value
    }
    
    //if nothing typed, restore 'placeholder' text in light gray color and restore Save button to original functionality
    func textViewDidEndEditing(_ textView: UITextView) {
        print("Description field done editing")
        if (tvReasoning.text == "") {
            tvReasoning.textColor = UIColor.lightGray
            tvReasoning.text = "Briefly explain why you are requesting a name change (such as marriage, divorce, or legally updated, etc..)"
        }
    }
    
    @IBAction func nextField(_ sender: UITextField) {
        if sender.accessibilityIdentifier == "newName" {
            print("Hit return on current password field")
            tfNewName.resignFirstResponder()
            tvReasoning.becomeFirstResponder()
        }
    }
}
