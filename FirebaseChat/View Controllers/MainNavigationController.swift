//
//  MainNavigationController.swift
//  FirebaseChat
//
//  Created by Alex Alexandrovych on 28/11/2016.
//  Copyright © 2016 Alex Alexandrovych. All rights reserved.
//

import UIKit
import Firebase

class MainNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = UIColor(red: 8/255, green: 164/255, blue: 225/255, alpha: 1.0)
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        view.backgroundColor = UIColor(red: 8/255, green: 164/255, blue: 225/255, alpha: 1.0)
        
        if isLoggedIn() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootVC = storyboard.instantiateViewController(withIdentifier: "GroupsTableViewController")
            viewControllers = [rootVC]
        } else {
            perform(#selector(showLoginController), with: nil, afterDelay: 0.01)
        }
    }
    
    fileprivate func isLoggedIn() -> Bool {
        return UserDefaults.standard.isLoggedIn()
    }
    
    func showLoginController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        present(loginVC, animated: true, completion: nil)

    }
}
