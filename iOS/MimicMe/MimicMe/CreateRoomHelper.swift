//
//  CreateRoomHelper.swift
//  MimicMe
//
//  Created by Full Name on 5/12/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit
import PKHUD

extension CreateRoomViewController {
    
    struct Bot: Decodable {
        let name: String
        let id: String
    }
    
    func sendToServer(roomName: String, bots: String) {
        
        // --------------------- Make an HTTP Request ----------------------------
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
                if ( error?._code == NSURLErrorTimedOut || error?._code == NSURLErrorNotConnectedToInternet)  {
                    DispatchQueue.main.async {
                        HUD.hide() // hide progress animation
                        self.displayAlertMessage("Check your Internet connection. Failed to connect with server")
                    }
                    return
                }
                print(error!.localizedDescription)
            }
            // check reponse status
            if let resp = response as? HTTPURLResponse {
                print("Create Room response status: ", resp.statusCode)
                if resp.statusCode == 201 {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: false, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.displayAlertMessage("Something went wrong. Try again later")
                    }
                }
            } // end outer if
            DispatchQueue.main.async {
                HUD.hide() // hide progress animation
            }
        }.resume()
    } // end send to server
    
    
    func getBotListFromServer() -> [Bot] {
        let bots = [Bot]()
        
        // make a header for request
        guard let url = URL(string: "http://159.65.38.56:8000/chat/create") else { return []}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type");
        
        // make a request
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                if ( error?._code == NSURLErrorTimedOut || error?._code == NSURLErrorNotConnectedToInternet)  {
                    DispatchQueue.main.async {
                        HUD.hide() // hide progress animation
                        self.displayAlertMessage("Check your Internet connection. Failed to connect with server")
                    }
                    return
                }
                print(error!.localizedDescription)
            }
            if let resp = response as? HTTPURLResponse {
                print("Get bots response code: ", resp.statusCode)
                if resp.statusCode == 200 {
                    guard let data = data else {return}
                    do {
                        self.bots = try JSONDecoder().decode([Bot].self, from: data) // decode as array of bots
                        DispatchQueue.main.async {
                            self.tableView.reloadData() // for bots to be displayed in the table
                        }
                    } catch { print("Could not parse bot JSON")}
                }
            } // end outer if
            DispatchQueue.main.async {
                HUD.hide() // hide progress animation
            }
         }.resume()
         return bots
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
