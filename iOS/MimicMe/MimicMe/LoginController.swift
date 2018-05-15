//
//  LoginController.swift
//  MimicMe
//
//  Created by Nikki Jack on 3/2/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit

// This view lets the user log in. In case of correct credentials
// it redirects to "Main" view.
// Also can trigger "Sign up" view for new users.
class LoginController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
     // Called when 'Done' key pressed to remove keyboard from screen
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // redirects to "Signup" view
    @IBAction func signupTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "noAccount", sender: self)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        nameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        let name =  nameTextField.text!
        let password = passwordTextField.text!
        
        // validate user input
        if ( name.isEmpty || password.isEmpty ) {
            displayAlertMessage("All fields are required")
            return
        }
        
        // Check with the backend if user credentials are correct.
        // In case of success saves token to phone memory.
        // isWorking is arg which is part of completion closure
        check(name: name,password: password) { (isWorking, id) in
            if isWorking {
                UserDefaults.standard.set(id, forKey: "secret")
                UserDefaults.standard.set(name, forKey: "uname")
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: nil)
                    self.performSegue(withIdentifier: "go", sender: self)
                }
            } else {
                print("************* UNFORSEEN SERVER ERROR *************************")
                DispatchQueue.main.async {
                    self.displayAlertMessage("Server Error. Please try again later")
                }
            }
        }
    } // end login tapped
} // end controller
