//
//  SignupHelper.swift
//  MimicMe
//
//  Created by Full Name on 5/12/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit

extension SignupController {
    
    func verifyAndSendToServer(name: String, email: String, password: String, passRepeat:String) {
        
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
        guard let url = URL(string: "http://159.65.38.56:8000/user/register") else { return }
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
            // check response status
            if let resp = response as? HTTPURLResponse {
                print("Signup status code: ", resp.statusCode)
                if resp.statusCode == 201 {
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                    }
                } else if resp.statusCode == 400 {
                    DispatchQueue.main.async {
                        self.displayAlertMessage("Username already in use. Please choose a different one")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.displayAlertMessage("Something went wrong. Try again later")
                    }
                }
            } // end outer if
        }.resume()
    } // end verify
    
    
    // displays given error message in a pop-up alert view
    // @param userMessage is the explanation of the error
    func displayAlertMessage(_ userMessage: String) {
        let theAlert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        theAlert.addAction(okAction)
        self.present(theAlert, animated: true, completion: nil)
    }
}
