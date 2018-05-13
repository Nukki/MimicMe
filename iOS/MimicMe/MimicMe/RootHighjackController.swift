//
//  RootHighjackController.swift
//  MimicMe
//
//  Created by Nikki Jack on 3/10/18.
//  Copyright © 2018 N. All rights reserved.
//

import UIKit

// The custom root controller.
// The main function of this view is to reroute to appropriate view
// depending if the user is logged in or not.
// If the user is not logged in, it will send it to "LoginController", otherwise
// it will show the "Main" view.
class RootHighjackController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
    }
    
    func showLoginController() {
        let loginController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as UIViewController
        self.present(loginController, animated: false, completion: {
            // empty for now
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userLoggedIn: String? = UserDefaults.standard.string(forKey: "secret")
        if userLoggedIn != nil {
            print("--------------------- Logged in ------------------------")
            let mainController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeScreen") as UIViewController
            viewControllers = [mainController]
        } else {
            print("--------------------- NOT logged in --------------------")
            perform(#selector(showLoginController), with: nil, afterDelay: 0.01)
        }
    }
}
