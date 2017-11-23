//
//  ViewController.swift
//  Chatty
//
//  Created by Relorie on 11/23/17.
//  Copyright © 2017 Relorie. All rights reserved.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.frame = CGRect(x: 160, y: 100, width: 50, height: 50)
        loginButton.layer.cornerRadius = 0.4 * loginButton.bounds.size.width
        loginButton.clipsToBounds = true
        loginButton.isEnabled = false
        
        passwordTextField.addTarget(self, action: #selector(self.handleTextField), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(self.handleTextField), for: UIControlEvents.editingChanged)
        passwordTextField.isSecureTextEntry = true
        
    }

    // MARK: Actions
    
    @IBAction func performLogin(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if let err = err {
                self.presentAlert(forError: err)
                return
            }
            self.performSegue(withIdentifier: "channelsLoginSegue", sender: self)
        }
    }
    
    @IBAction func loginAnonymously(_ sender: Any) {
        Auth.auth().signInAnonymously { (user, err) in
            if let err = err {
                self.presentAlert(forError: err)
                return
            }
            self.performSegue(withIdentifier: "channelsLoginSegue", sender: self)
        }
    }
    
    // MARK: Methods
    
    @objc func handleTextField() {
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
                loginButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
                loginButton.isEnabled = false
                return
        }
        loginButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        loginButton.isEnabled = true
    }
    
    private func presentAlert(forError err: Error) {
        let alert = UIAlertController.init(title: "Error!", message: err.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
}

