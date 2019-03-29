//
//  CustomNavController.swift
//  helpr
//
//  Created by Critical on 2019-03-28.
//  Copyright © 2019 ryan.konynenbelt. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func setNavBarAttributes() {
        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.tintColor = UIColor(named: "RoyalPurple")
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "RoyalPurple")]
        self.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "RoyalPurple")]
    }
}
