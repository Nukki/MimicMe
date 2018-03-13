//
//  MainViewController.swift
//  MimicMe
//
//  Created by Full Name on 3/1/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit
import Starscream

class MainViewController: UIViewController {
    
    var socket = WebSocket(url: URL(string: "http://192.168.0.7:3000/")!)
//    var socket = WebSocket(url: URL(string: "ws://echo.websocket.org")!)
//    var socket:WebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.disableSSLCertValidation = true
        socket.delegate = self
        socket.connect()
        self.navigationController?.isNavigationBarHidden = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
  
    
    
//    override func viewDidAppear(_ animated: Bool) {
    
        // if not logged in, go to login/signup (UnknownUser View)
//        let retrievedUser: String? = KeychainWrapper.standard.string(forKey: "userId")
//        let retrievedUser = UserDefaults.standard.string(forKey: "ayyy")
//        if retrievedUser != nil {
//             print("LOGGED IN")
//             print("retrieved in main ", retrievedUser!)
//        }
//        else {
//            self.performSegue(withIdentifier: "letmein", sender: self)
//        }
//    }
//
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "ayyy")
        print("tapped logout button")
        self.dismiss(animated: false, completion: nil)
        self.performSegue(withIdentifier: "letmein", sender: self)
    }
    
    
}

extension MainViewController : WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("------------------------------------- socket connect")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("did rec msg")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("did stuff")
    }
    
}
