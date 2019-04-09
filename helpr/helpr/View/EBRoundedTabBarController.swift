//
//  EBRoundedTabBarController.swift
//  RoundedTabBarControllerExample
//
//  Created by Erid Bardhaj on 10/28/18.
//  Copyright © 2018 Erid Bardhaj. All rights reserved.
//

import UIKit
import Firebase

class EBRoundedTabBarController: UITabBarController {
    let database = DatabaseHelper()
    
    // MARK: - Inner Types
    
    private struct Constants {
        static var actionButtonSize = CGSize(width: 64, height: 64)
    }
    
    
    // MARK: - Properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Immutable
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.backgroundColor = UIColor(named: "RoyalPurple")
        button.layer.cornerRadius = Constants.actionButtonSize.height/2
        
        button.addTarget(self, action: #selector(actionButtonTapped(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Auth.auth().currentUser?.uid != nil) {
            _ = Auth.auth().addStateDidChangeListener { (auth,user) in
                if (user != nil) {
                    self.database.getUser() { (user) -> () in
                        UserProfile.name = user!.name
                        UserProfile.email = user!.email
                        UserProfile.skills = user!.skills
                        UserProfile.profilePicRef = user!.picRef
                    }
                }
            }
        }
        
        setupSubviews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        actionButton.isHidden = false
    }
    
    
    // MARK: - Setups
    
    private func setupSubviews() {
        createTabbarControllers()
        
        view.addSubview(actionButton)
    }
    
    private func setupConstraints() {
        actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        actionButton.widthAnchor.constraint(equalToConstant: Constants.actionButtonSize.width).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: Constants.actionButtonSize.height).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: tabBar.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    
    // MARK: - Actions
    
    @objc private func actionButtonTapped(sender: UIButton) {
        let customViewController = storyboard?.instantiateViewController(withIdentifier: "PostAdTableViewController") as! PostAdTableViewController
        let navigationController = UINavigationController(rootViewController: customViewController)
        navigationController.setNavBarAttributes()
        present(navigationController, animated: true) {
            self.actionButton.isHidden = true
        }
    }
    
    
    // MARK: - Helpers
    private func createTabbarControllers() {
        let systemTags = [EBRoundedTabBarItem.explorePage, .jobsPage, .createPost, .messagesPage, .profilePage]
        let viewControllers = systemTags.compactMap { self.createController(for: $0, with: $0.tag) }
        
        self.viewControllers = viewControllers
    }
    
    private func createController(for customTabBarItem: EBRoundedTabBarItem, with tag: Int) -> UINavigationController? {
        var viewController = UIViewController()
        if (tag == 1) {
            viewController = storyboard?.instantiateViewController(withIdentifier: "NewExploreTableViewController") as! ExploreTableViewController
        }
        
        else if (tag == 2) {
            viewController = storyboard?.instantiateViewController(withIdentifier: "JobsTableViewController") as! JobsTableViewController
        }
        
        else if (tag == 4) {
            viewController = storyboard?.instantiateViewController(withIdentifier: "MessageTableViewController") as! MessageTableViewController
        }
        
        else if (tag == 5) {
            viewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        }
        
        viewController.tabBarItem = customTabBarItem.tabBarItem
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.setNavBarAttributes()
        return navigationController
    }
}

