//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Alex Alexandrovych on 27/10/2016.
//  Copyright © 2016 Alex Alexandrovych. All rights reserved.
//

import UIKit
import Firebase

struct Identifiers {
    static let segueIdentifier = "LoginToChat"
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var reference: FIRAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reference = FIRAuth.auth()
        reference.addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: Identifiers.segueIdentifier, sender: nil)
            } else {
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
            }
        }
    }
    
    @IBAction func login() {
        reference.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!)
        /*
        ref.signInAnonymously { (user, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
        */
    }
    
    @IBAction func signUp(_ sender: Any) {
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
                                        
            guard let email = emailField.text, let password = passwordField.text else {
                    return
            }
                                        
            self.reference.createUser(withEmail: email, password: password) { user, error in
                if error == nil {
                    self.login()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let chatVC = (segue.destination as? UINavigationController)?.viewControllers.first as? ChatViewController {
            chatVC.senderId = reference.currentUser?.uid ?? ""
            chatVC.senderDisplayName = reference.currentUser?.displayName ?? ""
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.resignFirstResponder()
        default:
            return false
        }
        return true
    }
    
}
