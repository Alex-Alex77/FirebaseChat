//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Alex Alexandrovych on 27/10/2016.
//  Copyright © 2016 Alex Alexandrovych. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: Properties
    var reference: FIRDatabaseReference!
    var user: FIRUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reference = FIRDatabase.database().reference()
        
    }

    @IBAction func loginDidTouch(_ sender: AnyObject) {
        FIRAuth.auth()?.signInAnonymously() { user, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            self.user = user
            self.performSegue(withIdentifier: "LoginToChat", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navVc = segue.destination as! UINavigationController
        let chatVc = navVc.viewControllers.first as! ChatViewController
        chatVc.senderId = user.uid
        chatVc.senderDisplayName = "Anonymussss"
    }
}

