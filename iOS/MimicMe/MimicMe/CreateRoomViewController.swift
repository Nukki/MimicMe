//
//  CreateRoomViewController.swift
//  MimicMe
//
//  Created by Nikki Jack on 5/4/18.
//  Copyright © 2018 N. All rights reserved.
//

import UIKit

class CreateRoomViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var roomNameTextField: UITextField!
    
    @IBAction func goTapped(_ sender: UIButton) {
        let roomName = roomNameTextField.text!
        roomNameTextField.resignFirstResponder()
        
        // ****************** Make an HTTP Request **********************************
        
        // make a header for request
        guard let url = URL(string: "http://159.65.38.56:8000/chat/create") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type");
        
        // encode data for request
        let postDictionary = ["name": roomName, "bots": "a list of bots will be here"]
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
                if let resp = response as? HTTPURLResponse {
                    if resp.statusCode == 201 {
                        print("ACCOUNT CREATED 201")
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                            self.dismiss(animated: false, completion: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                        self.displayAlertMessage("Something went wrong. Try again later")
                        }
                    }
                } // end if
//                self.dismiss(animated: false, completion: nil)
            } catch {}
        }.resume()
    } // end goTapped
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomNameTextField.delegate = self
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 96.0/255, green: 49.0/255, blue: 152.0/255, alpha: 1.0)
        navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.white
    }
    
    // Called when 'return' key pressed (keyboard disappears)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Hide navigation bar upon exit
    override func viewWillDisappear(_ animated: Bool) {
        roomNameTextField.resignFirstResponder()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // displays given error message in a pop-up alert view
    // @param userMessage is the explanation of the error
    func displayAlertMessage(_ userMessage: String) {
        let theAlert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        theAlert.addAction(okAction)
        self.present(theAlert, animated: true, completion: nil)
    }
} // end controller
