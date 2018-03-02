//
//  LoginController.swift
//  MimicMe
//
//  Created by Full Name on 3/2/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit

class LoginController : UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var loginSuccess = true
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        let email =  emailTextField.text!
        let pass = passwordTextField.text!
        
        // TODO check for empty input
        // sanitize input from injection?
        
        // change to conditional transition
        
        print("email")
        print(email)
        print("pass")
        print(pass)
    }
}
