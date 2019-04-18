//
//  CustomNavController.swift
//  helpr
//
//  Created by walter.alvarez on 2019-03-28.
//  Copyright © 2019 helpr. All rights reserved.
//
// nav bar extension to set app-wide attributes

import UIKit

extension UINavigationController {
    
    func setNavBarAttributes() {
        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.tintColor = UIColor(named: "RoyalPurple")
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "RoyalPurple")]
        self.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "RoyalPurple")]
    }
}
