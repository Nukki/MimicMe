//
//  SignupController.swift
//  MimicMe
//
//  Created by Full Name on 3/2/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit

class SignupController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
    }
    
    // Called when 'Done' key pressed, makes keyboard disappear
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // sign up button is tapped
    @IBAction func signupTapped(_ sender: UIButton) {
        let name = nameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let passRepeat = repeatPasswordTextField.text!
        verifyAndSendToServer(name: name,email: email,password: password,passRepeat: passRepeat)
    }
}
