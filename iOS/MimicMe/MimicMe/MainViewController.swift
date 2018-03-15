//
//  MainViewController.swift
//  MimicMe
//
//  Created by Full Name on 3/1/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
//          var socket = WebSocket(url: URL(string: "ws://127.0.0.1:8000/socket")!)
//    var socket = WebSocket(url: URL(string: "ws://192.168.0.7:8000/socket")!)
//    var socket = WebSocket(url: URL(string: "ws://echo.websocket.org")!)
//    var socket:WebSocket?
//    var request = URLRequest(url: URL(string: "ws://127.0.0.1:8000/socket")!)
   
    override func viewDidLoad() {
        super.viewDidLoad()
//        request.timeoutInterval = 5
//        let token = "044e9ce212700f614afc5f83efcec6c1de5f81d8"
//        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
//        let socket = WebSocket(request: request)
//            socket.disableSSLCertValidation = true
//            socket.delegate = self
//            socket.connect()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "ayyy")
        self.dismiss(animated: false, completion: nil)
        self.performSegue(withIdentifier: "letmein", sender: self)
    }
}



