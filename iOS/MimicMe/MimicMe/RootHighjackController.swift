//
//  RootHighjackController.swift
//  MimicMe
//
//  Created by Full Name on 3/10/18.
//  Copyright © 2018 N. All rights reserved.
//

import UIKit

class RootHighjackController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red

//        let userLoggedIn: String? = UserDefaults.standard.string(forKey: "ayyy")
//        if userLoggedIn != nil {
//            //user is logged in
//            print("Loggedin")
//            let mainController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeScreen") as UIViewController
//            viewControllers = [mainController]
//        } else {
//            print("not logged in")
//            perform(#selector(showLoginController), with: nil, afterDelay: 0.01)
//        }
    }
    
    func showLoginController() {
        let loginController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as UIViewController
        self.present(loginController, animated: false, completion: {
            // empty for now
        })
    }
    
    func showMainController() {
        let loginController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeScreen") as UIViewController
        self.present(loginController, animated: false, completion: {
            // empty for now
        })
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? LoginController {
//            destination.delegate = self
//        }
//    }
    
//    func finishPassing(string: String) {
//        print("Notified")
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userLoggedIn: String? = UserDefaults.standard.string(forKey: "ayyy")
        if userLoggedIn != nil {
            //user is logged in
            print("Loggedin")
            
// -------->           perform(#selector(showMainController), with: nil, afterDelay: 0.01)
            
            let mainController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeScreen") as UIViewController
            viewControllers = [mainController]
        } else {
            print("not logged in")
            
//            let mainController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as UIViewController
//            viewControllers = [mainController]
            
            perform(#selector(showLoginController), with: nil, afterDelay: 0.01)
        }
    }
    
    
}

