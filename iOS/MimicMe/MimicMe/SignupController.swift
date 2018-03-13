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
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
   
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    @IBAction func signupTapped(_ sender: UIButton) {
        let name = nameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let passRepeat = repeatPasswordTextField.text!
        
        // TODO check for injections
        // case when the email is already in use???
        // post it to Keychain and to server?
      
        // ***************** User Input Validation ********************************
        
        if (name.isEmpty || email.isEmpty || password.isEmpty || passRepeat.isEmpty) {
            displayAlertMessage("All fields are required")
            return
        }
        if (password != passRepeat) {
            displayAlertMessage("Passwords do not match")
            return
        }
        if (password.count < 8 ) {
            displayAlertMessage("Password should be at least 8 characters long")
            return
        }
        
        
        // ****************** Make an HTTP Request **********************************
        
        // make a header for request
        guard let url = URL(string: "http://127.0.0.1:8000/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type");
        
        // encode data for request
        let postDictionary = ["name": name, "email": email, "password" : password]
        do {
            let jsonBody =  try JSONEncoder().encode(postDictionary)
            request.httpBody = jsonBody
        } catch { }
        
        
        // make a request
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else {return}
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
                // which view to go next
                self.dismiss(animated: false, completion: nil)
//                self.displayAlertMessage("come onnnn")
                
            } catch {}
        }.resume()
        
        
    }
    
    // displays given error message in a pop-up alert view
    // @param userMessage is the explanation of the error
    func displayAlertMessage(_ userMessage: String) {
        let theAlert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        theAlert.addAction(okAction)
        self.present(theAlert, animated: true, completion: nil)
    }
    
}
