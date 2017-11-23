//
//  RegisterViewController.swift
//  Chatty
//
//  Created by Relorie on 11/23/17.
//  Copyright © 2017 Relorie. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: Vars
    
    var ref = Database.database().reference()
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.frame = CGRect(x: 160, y: 100, width: 50, height: 50)
        registerButton.layer.cornerRadius = 0.4 * registerButton.bounds.size.width
        registerButton.clipsToBounds = true
        
        passwordTextField.addTarget(self, action: #selector(self.handleTextField), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(self.handleTextField), for: UIControlEvents.editingChanged)
        
        passwordTextField.isSecureTextEntry = true
        
        }

    // MARK: Actions
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func performRegistration(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
            if let err = err {
                self.presentAlert(forError: err)
                return
            }
            self.saveUserToDatabase(user)
            self.performSegue(withIdentifier: "channelsRegisterSegue", sender: self)
        }
    }
    
    // MARK: Methods
    
    fileprivate func saveUserToDatabase(_ user: User?) {
        let newUser = ref.child("users").childByAutoId()
        let userData = [
            "name" : usernameTextField.text!,
            "email" : emailTextField.text!
        ]
        newUser.setValue(userData)
    }
    
    @objc func handleTextField() {
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty,
            let username = usernameTextField.text,
            !username.isEmpty else {
                registerButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
                registerButton.isEnabled = false
                return
        }
        registerButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        registerButton.isEnabled = true
    }
    
    private func presentAlert(forError err: Error) {
        let alert = UIAlertController.init(title: "Error!", message: err.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "channelsRegisterSegue" {
            let nc = segue.destination as! UINavigationController
            let channelsVC = nc.topViewController as! ChannelsViewController
            channelsVC.username = usernameTextField.text!
        }
    }

}
