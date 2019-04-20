//
//  EBRoundedTabBarItem.swift
//  RoundedTabBarControllerExample
//
//  Created by Erid Bardhaj on 10/28/18.
//  Copyright © 2018 Erid Bardhaj. All rights reserved.
//
// assign each tab bar item's values for custom tab bar

import UIKit

enum EBRoundedTabBarItem {
    case explorePage, jobsPage, createPost, messagesPage, profilePage
    
    var isRoundedItem: Bool {
        if case self = EBRoundedTabBarItem.createPost {
            return true
        }
        
        return false
    }
}

extension EBRoundedTabBarItem {
    //tab bar item page titles
    var title: String {
        switch self {
        case .explorePage:
            return "Explore"
        case .jobsPage:
            return "Jobs"
        case .createPost:
            return ""
        case .messagesPage:
            return "Messages"
        case .profilePage:
            return "Profile"
        }    }
    
    var isEnabled: Bool {
        return !isRoundedItem
    }
    //tab bar item index values
    var tag: Int {
        switch self {
        case .explorePage:
            return 1
        case .jobsPage:
            return 2
        case .createPost:
            return 3
        case .messagesPage:
            return 4
        case .profilePage:
            return 5
        }
    }
    //tab bar item icons
    var image: UIImage? {
        switch self {
        case .explorePage:
            return #imageLiteral(resourceName: "explore")
        case .jobsPage:
            return #imageLiteral(resourceName: "jobs")
        case .createPost:
            return nil
        case .messagesPage:
            return #imageLiteral(resourceName: "messages")
        case .profilePage:
            return #imageLiteral(resourceName: "account")
        }
    }
    
    var tabBarItem: UITabBarItem {
        let tabItem = UITabBarItem(title: title, image: image, tag: tag)
        tabItem.isEnabled = isEnabled
        return tabItem
    }
    
    var backgroundColor: UIColor {
        return .white
    }
}

