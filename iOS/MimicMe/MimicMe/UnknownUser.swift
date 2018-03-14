//
//  UnknownUser.swift
//  MimicMe
//
//  Created by Full Name on 3/2/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit

class UnknownUser : UIViewController {
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    @IBAction func loginTapped(_ sender: UIButton) {
         presentingViewController?.dismiss(animated: false, completion:nil)
      
            performSegue(withIdentifier: "toLogin", sender: self)
        
        
    }
    @IBAction func signupTapped(_ sender: UIButton) {
         presentingViewController?.dismiss(animated: false, completion:nil)
//           dismiss(animated: false, completion: nil)
//            navigationController?.popViewController(animated: true)
            shouldPerformSegue(withIdentifier: "toSignup", sender: self)
    }
    
}
