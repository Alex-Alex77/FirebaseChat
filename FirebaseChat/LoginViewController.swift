//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Alex Alexandrovych on 27/10/2016.
//  Copyright © 2016 Alex Alexandrovych. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin

final class LoginViewController: UIViewController {
    
    private struct Identifiers {
        static let segueIdentifier = "Login"
    }
    
    @IBOutlet fileprivate weak var emailTextField: UITextField! { didSet { emailTextField.delegate = self } }
    @IBOutlet fileprivate weak var passwordTextField: UITextField! { didSet { passwordTextField.delegate = self } }
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaFacebookButton: UIButton!
    
    var reference: FIRAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 10.0
        loginViaFacebookButton.layer.cornerRadius = 10.0
        
//        let facebookLoginButton = UIButton()
//        facebookLoginButton.center = view.center
//        view.addSubview(facebookLoginButton)

        reference = FIRAuth.auth()

        reference.addStateDidChangeListener() { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: Identifiers.segueIdentifier, sender: nil)
            }
        }
        passwordTextField?.text = ""
    }
    
    @IBAction func loginViaFacebook() {
        LoginManager().logIn([.email, .publicProfile], viewController: self) { result in
            switch result {
            case .failed(let error):
                print("Failed with error: \(error.localizedDescription)")
            case .cancelled:
                print("cancelled!")
            case .success(_, _, let accessToken):
                let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                self.reference.signIn(with: credentials) { (user, error) in
                    guard error == nil else {
                        print("There was an error during login process: \(error!.localizedDescription)")
                        return
                    }
                    if user != nil {
                        self.performSegue(withIdentifier: Identifiers.segueIdentifier, sender: nil)
                    } else {
                        print("User is nil")
                    }
                }

            }
        }
    }
    
    @IBAction func login() {
        if let email = emailTextField.text,
            let password = passwordTextField.text,
            email.characters.count > 0 && password.characters.count > 0 {
            reference.signIn(withEmail: email, password: password) { (user, error) in
                guard error == nil else {
                    print("There was an error during login process: \(error!.localizedDescription)")
                    return
                }
                if user != nil {
                    self.performSegue(withIdentifier: Identifiers.segueIdentifier, sender: nil)
                } else {
                    print("User is nil")
                }
            }
        }

    }
    
    @IBAction func signUp(_ sender: Any) {
        let alert = UIAlertController(title: "Sign up",
                                      message: "You need to enter:",
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
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let groupVC = (segue.destination as? UINavigationController)?.viewControllers.first as? GroupsTableViewController {
        
            groupVC.senderDisplayName = reference.currentUser?.displayName ?? "Noname"
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
            login()
        default:
            return false
        }
        return true
    }
    
}
