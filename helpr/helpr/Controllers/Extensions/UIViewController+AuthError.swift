//
//  UIViewController+AuthError.swift
//  helpr
//
//  Created by walter alvarez and adrian parcioaga on 2018-11-25.
//  Copyright © 2018 helpr. All rights reserved.
//
import UIKit
import Firebase
extension UIViewController{
    func handleError(_ error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            print(errorCode.errorMessage)
            let alert = UIAlertController(title: "Error", message: errorCode.errorMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
}
