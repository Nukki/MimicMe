//
//  LoginHelper.swift
//  MimicMe
//
//  Created by Full Name on 5/12/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit

extension LoginController {
    
    // struct for parsing JSON to get the uid
    struct IdFromJson: Decodable {
        let response: String
        let uid: Int
    }
    
    // Sends a request to server to verify the username and password correctness
    // Saves response results with isWorking closure
    // @param username and password from user input
    func check(name : String, password: String, completion: @escaping (_ isWorking: Bool, _ id: Int)->()) {
        // make a header for HTTP request
        guard let url = URL(string: "http://159.65.38.56:8000/user/login") else { return }
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
            // check server response code
            if let resp = response as? HTTPURLResponse {
                print("Login response status: ", resp.statusCode)
                // if response SUCCESS, then parse JSON and pass uid in a closure
                if resp.statusCode == 200 {
                    guard let data = data else {return}
                    do {
                        let responseJson = try JSONDecoder().decode(IdFromJson.self, from: data)
                        completion(true, responseJson.uid)
                    } catch { print("Could not parse JSON") }
                } else if resp.statusCode == 500  {
                    DispatchQueue.main.async {
                        print("************* WRONG CREDENTIALS *************************")
                        self.displayAlertMessage("Wrong username and/or password. Please try again")
                    }
                } else {
                    completion(false, -1)
                }
            } // end outer if
            
            }.resume()
    } // end check func
    
    // displays given error message in a pop-up alert view
    // @param userMessage is the explanation of the error
    func displayAlertMessage(_ userMessage: String) {
        let theAlert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        theAlert.addAction(okAction)
        self.present(theAlert, animated: true, completion: nil)
    }
}
