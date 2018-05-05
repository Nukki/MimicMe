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
    
     // Called when 'return' key pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // redirects to "Signup" view
    @IBAction func signupTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "noAccount", sender: self)
    }
    
    override func viewDidLoad(){
        nameTextField.delegate = self
        passwordTextField.delegate = self
        super.viewDidLoad()
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        let name =  nameTextField.text!
        let password = passwordTextField.text!
        
        // ***************** User Input Validation *************************
        
        if ( name.isEmpty || password.isEmpty ) {
            displayAlertMessage("All fields are required")
            return
        }
        
        // Checks with the backend if user credentials are correct.
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
                print("************* WRONG CREDENTIALS *************************")
                DispatchQueue.main.async {
                    self.displayAlertMessage("Wrong Credentials")
                }
            }
        }
    } // end loginTapped
    
    
    // displays given error message in a pop-up alert view
    // @param userMessage is the explanation of the error
    func displayAlertMessage(_ userMessage: String) {
        let theAlert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        theAlert.addAction(okAction)
        self.present(theAlert, animated: true, completion: nil)
    }
    
    // Sends a request to server to verify the username and password correctness
    // Saves response results with isWorking closure
    // @param username and password from user input
    func check(name : String, password: String, completion: @escaping (_ isWorking: Bool, _ id: Int)->()) {
        // make a header for HTTP request
        guard let url = URL(string: "http://127.0.0.1:8000/user/login") else { return }
//        guard let url = URL(string: "http://192.168.0.2:8000/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type");
        
        // encode data for request
        let postDictionary = [ "name": name, "password" : password]
        do {
            let jsonBody =  try JSONEncoder().encode(postDictionary)
            request.httpBody = jsonBody
        } catch { }
        
        // make a request
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response:  URLResponse!, error) in
            if error != nil {
                print(error!.localizedDescription)
                DispatchQueue.main.async {
                    self.displayAlertMessage("No connection to server. Please try again later")
                }
            }
            guard let data = data else {return}
            print(" ++++++++++++++ got data ++++++++++++++++++")
            do {
                let responseJson = try JSONDecoder().decode(IdFromJson.self, from: data) // decode as array of roomfromJson struct
                print("ID is: ", responseJson.uid)
//                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
//                print(json)
                
                // if status code is 200 save the auth id and go to main screen , else display error
                if let resp = response as? HTTPURLResponse {
                    if resp.statusCode == 200 {
                        print("LOGIN STATUS 200")
                        completion(true, responseJson.uid)
                    } else {
                        completion(false, -1)
                    }
                }
                return
            } catch { print("CONNECTION PROBLEM")}
            }.resume()
    } // end check func
}

// struct for parsing JSON to get the uid
struct IdFromJson: Decodable {
    let response: String
    let uid: Int
}
