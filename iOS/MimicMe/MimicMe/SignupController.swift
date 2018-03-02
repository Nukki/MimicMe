//
//  SignupController.swift
//  MimicMe
//
//  Created by Full Name on 3/2/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit

class SignupController : UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    @IBAction func signupTapped(_ sender: UIButton) {
        let email = emailTextField.text!
        let pass = passwordTextField.text!
        let passRepeat = repeatPasswordTextField.text!
        
        print(email,pass,passRepeat)
        
        // TODO check empty fields and injections
        // check if passwords match
        // post it to Keychain and to server?
        
    }
    
}
